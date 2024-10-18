
#include <Eigen/Core>
#include <Eigen/Dense>
#include <Eigen/StdVector>
#include <chrono>
#include <dynamic_window_approach.hpp>
#include <functional>
#include <iostream>
#include <map>
#include <utility>
#include <vector>

DynamicWindowApproach::DynamicWindowApproach() {
}

/**
 * @brief Sets the obstacles for the dynamic window approach.
 *
 * This function sets the obstacles for the dynamic window approach algorithm.
 * The obstacles are represented by their x and y coordinates.
 *
 * @param obstacles_x The x coordinates of the obstacles.
 * @param obstacles_y The y coordinates of the obstacles.
 */
void DynamicWindowApproach::set_obstacles(std::vector<double> obstacles_x, std::vector<double> obstacles_y) {

	OBSTACLES_X = obstacles_x;
	OBSTACLES_Y = obstacles_y;
}

void DynamicWindowApproach::set_goal(std::array<double, 2> goal) {
	GOAL = goal;
}

/**
 * @brief Calculates the next state of the robot using the dynamic window approach.
 *
 * This function takes the current state of the robot, the linear velocity (v),
 * angular velocity (w), and the time step (dt) as input parameters. It calculates
 * the next state of the robot based on the current state and the specified velocities.
 *
 * @param state The current state of the robot, represented as a vector with 5 elements.
 *              The elements represent the x-coordinate, y-coordinate, orientation, linear
 *              velocity, and angular velocity of the robot, respectively.
 * @param v The linear velocity of the robot.
 * @param w The angular velocity of the robot.
 * @param dt The time step.
 * @return The next state of the robot, represented as a vector with 5 elements.
 *         The elements represent the x-coordinate, y-coordinate, orientation, linear
 *         velocity, and angular velocity of the robot, respectively.
 */
Vector DynamicWindowApproach::motion(Vector state, double v, double w, double dt) {
	Vector next_state(5);
	next_state[0] = state[0] + v * std::cos(state[2]) * dt;
	next_state[1] = state[1] + v * std::sin(state[2]) * dt;
	next_state[2] = state[2] + w * dt;
	next_state[3] = v;
	next_state[4] = w;
	return next_state;
}

std::pair<std::pair<double, double>, Matrix> DynamicWindowApproach::dwa_control(Vector state) {

	Vector dynamicWindow = calc_dynamic_window(state);
	return calc_control_and_trajectory(state, dynamicWindow);
}

/**
 * Calculates the dynamic window for the given state.
 *
 * @param state The current state of the robot.
 * @return The dynamic window as a vector containing the minimum and maximum translation velocities,
 *         as well as the minimum and maximum rotation velocities.
 */
Vector DynamicWindowApproach::calc_dynamic_window(Vector state) {

	Vector Vd(4);
	Vd << state[3] - config.acceleration_limit * config.dt, state[3] + config.acceleration_limit * config.dt,
	    state[4] - config.angular_acceleration_limit * config.dt,
	    state[4] + config.angular_acceleration_limit * config.dt;
	Vector dw(4);
	dw << std::max(config.min_translation_velocity, Vd[0]), std::min(config.max_translation_velocity, Vd[1]),
	    std::max(config.min_rotation_velocity, Vd[2]), std::min(config.max_rotation_velocity, Vd[3]);
	return dw;
}

/**
 * Predicts the trajectory of the robot based on the given state, velocity, and angular velocity.
 *
 * @param state The current state of the robot.
 * @param v The linear velocity of the robot.
 * @param w The angular velocity of the robot.
 * @return The predicted trajectory of the robot as a matrix, where each row represents a state of the robot at a
 * specific time step.
 */
Matrix DynamicWindowApproach::predict_trajectory(Vector state, double v, double w) {
	Matrix trajectory(1, state.size());
	trajectory.row(0) = state;
	double time = 0;
	while (time <= config.predict_time) {
		state = motion(state, v, w, config.dt);
		trajectory.conservativeResize(trajectory.rows() + 1, state.size()); // Add the new state
		trajectory.row(trajectory.rows() - 1) = state;
		time += config.dt;
	}
	return trajectory;
}

/**
 * Calculates the control inputs and trajectory for the dynamic window approach algorithm.
 *
 * @param state The current state of the robot.
 * @param dw The dynamic window representing the range of allowable velocities and angular velocities.
 * @return A pair containing the best control inputs and the corresponding trajectory.
 */
std::pair<std::pair<double, double>, Matrix> DynamicWindowApproach::calc_control_and_trajectory(Vector state,
                                                                                                Vector dw) {
	double min_cost = std::numeric_limits<double>::infinity();
	Matrix best_trajectory;

	std::pair<double, double> best_u;
	auto start_global = std::chrono::high_resolution_clock::now();
	for (double v = dw[0]; v <= dw[1]; v += config.v_resolution) {
		for (double w = dw[2]; w <= dw[3]; w += config.w_resolution) {

			Matrix trajectory = predict_trajectory(state, v, w);
			double to_goal_cost = config.goal_distance_bias * calc_to_goal_cost(trajectory);
			double speed_cost =
			    config.speed_bias * (config.max_translation_velocity - trajectory.row(trajectory.rows() - 1)(3));
			double obstacle_cost = config.obstacle_distance_bias * calc_obstacle_cost(trajectory);
			double final_cost = to_goal_cost + speed_cost + obstacle_cost;

			// std::cout << "v: " << v << ", w: " << w << ", cost: " << final_cost << std::endl;
			if (final_cost < min_cost) {
				min_cost = final_cost;
				best_trajectory = trajectory;
				best_u = std::make_pair(v, w);
			}
		}
	}
	auto end_global = std::chrono::high_resolution_clock::now();
	std::chrono::duration<double> elapsed_time_global = end_global - start_global;
	std::cout << "Time taken for the entire loop: " << elapsed_time_global.count() << " seconds" << std::endl;
	return make_pair(best_u, best_trajectory);
}

/**
 * Calculates the obstacle cost for a given trajectory.
 *
 * @param trajectory The trajectory to calculate the obstacle cost for.
 * @return The obstacle cost for the trajectory. This is an double.
 */
double DynamicWindowApproach::calc_obstacle_cost(Matrix trajectory) {

	if (OBSTACLES_X.empty() || OBSTACLES_Y.empty()) {
		return 0;
	}
	auto start = std::chrono::high_resolution_clock::now();
	Vector ob_x = Vector::Map(OBSTACLES_X.data(), OBSTACLES_X.size());
	Vector ob_y = Vector::Map(OBSTACLES_Y.data(), OBSTACLES_Y.size());

	Matrix dx =
	    trajectory.col(0).replicate(1, ob_x.size()).array() - ob_x.transpose().replicate(trajectory.rows(), 1).array();

	Matrix dy =
	    trajectory.col(1).replicate(1, ob_y.size()).array() - ob_y.transpose().replicate(trajectory.rows(), 1).array();

	Matrix r = (dx.array().square() + dy.array().square()).sqrt();
	auto min_distance = r.minCoeff();
	if (min_distance < config.radius) {
		return std::numeric_limits<double>::infinity();
	}
	return 1.0 / r.minCoeff();
}

/**
 * Calculates the cost to the goal for a given trajectory.
 *
 * @param trajectory The trajectory to calculate the cost for.
 * @return The cost to the goal for the given trajectory. This is a double.
 */
double DynamicWindowApproach::calc_to_goal_cost(Matrix trajectory) {
	Vector dx = trajectory.col(0).array() - GOAL[0];
	Vector dy = trajectory.col(1).array() - GOAL[1];
	Vector r = (dx.array().square() + dy.array().square()).array().sqrt();
	double goal_magnitude = r.minCoeff();
	return goal_magnitude;
}