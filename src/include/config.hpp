#ifndef CONFIG_HPP
#define CONFIG_HPP

#include <vector>

class Config {
public:
	// void populate_obstacle_list();

	constexpr static double min_translation_velocity = 0.1;
	constexpr static double min_rotation_velocity = -1.0;
	constexpr static double max_rotation_velocity = 1.0;
	constexpr static double max_translation_velocity = 1.0;

	constexpr static double radius = 0.22;
	constexpr static double acceleration_limit = 1.0;
	constexpr static double angular_acceleration_limit = 1.0;

	constexpr static double v_resolution = 0.1;
	constexpr static double w_resolution = 0.1;

	constexpr static double dt = 0.1;
	constexpr static int predict_time = 5;

	constexpr static double position_tolerance = 0.01;
	constexpr static double angle_tolerance = 0.01;

	constexpr static double goal_distance_bias = 1.0;
	constexpr static double speed_bias = 0.5;
	constexpr static double obstacle_distance_bias = 1.0;
};

#endif // CONFIG_HPP