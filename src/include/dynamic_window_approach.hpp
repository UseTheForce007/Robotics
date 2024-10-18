#ifndef DYNAMIC_WINDOW_APPROACH_HPP
#define DYNAMIC_WINDOW_APPROACH_HPP
#include <Eigen/Dense>
#include <array>
#include <config.hpp>
#include <utility>
#include <vector>

using Vector = Eigen::VectorXd;
using Matrix = Eigen::MatrixXd;

class DynamicWindowApproach {
public:
	DynamicWindowApproach();
	std::pair<std::pair<double, double>, Matrix> dwa_control(Vector state);
	void set_obstacles(std::vector<double> obstacles_x, std::vector<double> obstacles_y);
	void set_goal(std::array<double, 2> goal);
	Vector motion(Vector state, double v, double w, double dt);
	Config config;

private:
	Vector calc_dynamic_window(Vector state);
	std::pair<std::pair<double, double>, Matrix> calc_control_and_trajectory(Vector state, Vector dw);
	Matrix predict_trajectory(Vector state, double v, double y);

	double calc_obstacle_cost(Matrix trajectory);
	double calc_to_goal_cost(Matrix trajectory);

	std::vector<double> OBSTACLES_X;
	std::vector<double> OBSTACLES_Y;

	std::array<double, 2> GOAL;
};
#endif // DYNAMIC_WINDOW_APPROACH_HPP