#include <array>
#include <dynamic_window_approach.hpp>
#include <matplotlibcpp.h>

namespace plt = matplotlibcpp;

#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

// Function to read CSV file and populate x and y vectors
void readCSV(std::string const& filename, std::vector<double>& x_values, std::vector<double>& y_values) {
	// Open the CSV file

	if (!std::filesystem::exists(filename)) {
		std::cerr << "Error: File does not exist at the given path: " << filename << std::endl;
		return;
	}
	std::ifstream file(filename);

	// Check if the file is open
	if (!file.is_open()) {
		std::cerr << "Could not open the file!" << std::endl;
		return;
	}

	std::string line;
	// Skip the header line
	std::getline(file, line);

	// Read the file line by line
	while (std::getline(file, line)) {
		std::stringstream ss(line);
		std::string x_str, y_str;

		// Extract x and y values from the line
		std::getline(ss, x_str, ',');
		std::getline(ss, y_str, ',');

		// Convert strings to double and store them in vectors
		x_values.push_back(std::stod(x_str));
		y_values.push_back(std::stod(y_str));
	}

	// Close the file
	file.close();
}

int main() {
	DynamicWindowApproach dwa;
	Vector state(5);
	state << 0, 9, 0, 0, 0;
	std::array<double, 2> goal = {2, 2};

	std::vector<double> x_values;
	std::vector<double> y_values;
	std::string filepath = "../../../../data/obstacles_original.csv";
	readCSV(filepath, x_values, y_values);
	dwa.set_obstacles(x_values, y_values);
	std::array<double, 5> state_array;
	dwa.set_goal(goal);
	bool reached_goal = false;

	while (!reached_goal) {

		auto [u, trajectory] = dwa.dwa_control(state);

		state = dwa.motion(state, u.first, u.second, 0.1);

		state_array = {state[0], state[1], state[2], state[3], state[4]};

		Eigen::VectorXd first_column = trajectory.col(0);
		Eigen::VectorXd second_column = trajectory.col(1);

		// Convert to std::vector
		std::vector<double> x_trajectory(first_column.data(), first_column.data() + first_column.size());
		std::vector<double> y_trajectory(second_column.data(), second_column.data() + second_column.size());

		// Plot the current state and trajectory
		plt::clf();
		plt::plot(x_trajectory, y_trajectory, "r-");
		plt::plot({state[0]}, {state[1]}, "bo");
		plt::plot({goal[0]}, {goal[1]}, "go");
		plt::plot(x_values, y_values, "kx"); // Plot obstacles as black 'x'
		plt::pause(0.01);

		// Check if the robot has reached the goal
		if (std::sqrt(std::pow(state[0] - goal[0], 2) + std::pow(state[1] - goal[1], 2)) < 0.5) {
			reached_goal = true;
			std::cout << "Goal reached!" << std::endl;
		}
	}

	plt::pause(5);
	return 0;
}