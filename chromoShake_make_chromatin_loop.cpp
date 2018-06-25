#define _USE_MATH_DEFINES
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "unitConversion.h"

typedef double  POINT[2];

void usage(const char *name)
{
	fprintf(stderr, "Usage: %s [-option value] [outfile]\n", name);
	fprintf(stderr, "     outfile: Name of the output file to write to (default stdout)\n");
	fprintf(stderr, "     -loop_radius (microns) (default 0.5)\n");
	fprintf(stderr, "     -coh_radius (microns) (default 0.0255)\n");
	fprintf(stderr, "     -rings: number of cohesin rings (default 0)\n");
	fprintf(stderr, "     -node_separation (microns) (default 0.01\n");
	fprintf(stderr, "     -temperature (Celsius) (default 25)\n");
	fprintf(stderr, "     -viscosity (centiPoise) (default 1.5e-5)\n");
	fprintf(stderr, "         (Water = 1, but we use this to scale time)\n");
	fprintf(stderr, "         (Smaller runs faster but can make the simulation unstable)\n");
	fprintf(stderr, "     -damping_radius_factor: Multiplied by node_separation to determine effective radius for damping (ratio) (default 0.8)\n");
	fprintf(stderr, "     -time_step (nanoseconds) (default 2)\n");
	fprintf(stderr, "         (Longer time steps run faster but can make the simulation unstable\n");
	fprintf(stderr, "     -modulus: Young's modulus of DNA (gigaPascal) (default 2)\n");
	fprintf(stderr, "     -dna_radius: Radius of B-form DNA (nanometers) (default 0.6)\n");
	fprintf(stderr, "         (The collision/visual radius will be larger than this)\n");
	fprintf(stderr, "     -collision_radius_factor: Fraction of distance collision spheres will cover (default 0.9)\n");
	fprintf(stderr, "     -collision_force_factor: Number of times the spring constant to use for collision response (default 0.25)\n");
	fprintf(stderr, "     -spring_damping_factor: Ratio of drag constant from relative velocity of springs to spring constants (default 0)\n");
	fprintf(stderr, "    -seed: Specify the seed value for the random number generator\n");
	fprintf(stderr, "        (default is 42)\n");
	exit(-1);
}

int main(int argc, char *argv[])
{
	// Constants (could become command-line arguments).
	const char *outfile_name = NULL;
	double	loop_radius_microns = 0.5;
	double cohesin_radius_microns = 0.0255;
	int		num_rings = 0;
	double	mass_separation_microns = 0.01;
	double  temperature_Celsius = 25;
	double  viscosity_centiPoise = 1;
	double  time_step_nanoseconds = 2;
	double  modulus_gigaPascal = 2;
	double  dna_radius_nanometers = 0.6;
	double  collision_radius_factor = 0.9;
	double  collision_force_factor = 0.25;
	double  spring_damping_factor = 0.0;
	double  damping_radius_factor = 0.8;
	int random_number_seed = 42;

	// Parse the command line to adjust default values.
	int i;
	unsigned  real_params = 0;  //< Number of non-flag parameters
	for (i = 1; i < argc; i++) {
		if (!strcmp(argv[i], "-loop_radius")) {
			if (++i >= argc) { usage(argv[0]); }
			loop_radius_microns = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-coh_radius")) {
			if (++i >= argc) { usage(argv[0]); }
			cohesin_radius_microns = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-rings")) {
			if (++i >= argc) { usage(argv[0]); }
			num_rings = atoi(argv[i]);
		}
		else if (!strcmp(argv[i], "-node_separation")) {
			if (++i >= argc) { usage(argv[0]); }
			mass_separation_microns = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-temperature")) {
			if (++i >= argc) { usage(argv[0]); }
			temperature_Celsius = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-viscosity")) {
			if (++i >= argc) { usage(argv[0]); }
			viscosity_centiPoise = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-damping_radius_factor")) {
			if (++i >= argc) { usage(argv[0]); }
			damping_radius_factor = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-time_step")) {
			if (++i >= argc) { usage(argv[0]); }
			time_step_nanoseconds = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-modulus")) {
			if (++i >= argc) { usage(argv[0]); }
			modulus_gigaPascal = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-dna_radius")) {
			if (++i >= argc) { usage(argv[0]); }
			dna_radius_nanometers = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-collision_radius_factor")) {
			if (++i >= argc) { usage(argv[0]); }
			collision_radius_factor = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-collision_force_factor")) {
			if (++i >= argc) { usage(argv[0]); }
			collision_force_factor = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-spring_damping_factor")) {
			if (++i >= argc) { usage(argv[0]); }
			spring_damping_factor = atof(argv[i]);
		}
		else if (!strcmp(argv[i], "-random_number_seed")) {
			if (++i >= argc) { usage(argv[0]); }
			random_number_seed = atoi(argv[i]);
		}
		else {
			switch (real_params++) {
			case 0:
				outfile_name = argv[i];
				break;
			default:
				usage(argv[0]);
			}
		}
	}

	// Compute the derived values that we feed to the simulator.
	double  time_step_seconds = nanoseconds_to_seconds(time_step_nanoseconds);
	double	loop_radius_meters = microns_to_meters(loop_radius_microns);
	double	cohesin_radius_meters = microns_to_meters(cohesin_radius_microns);
	double  node_separation_meters = microns_to_meters(mass_separation_microns);
	double	mass_kg = dna_mass_in_kg(node_separation_meters);
	double  temperature_kelvin = Celsius_to_Kelvin(temperature_Celsius);
	double  viscosity_Pascal_seconds = centiPoise_to_Pascal_seconds(viscosity_centiPoise);
	double  dna_radius_meters = nanometers_to_meters(dna_radius_nanometers);
	double	effective_damping_radius = damping_radius_factor * node_separation_meters;

	double	spring_constant = dna_tensile_spring_constant(
		node_separation_meters,
		gigaPascal_to_Pascal(modulus_gigaPascal),
		dna_radius_meters
		);
	double	hinge_constant = dna_bending_spring_constant(
		node_separation_meters,
		gigaPascal_to_Pascal(modulus_gigaPascal),
		dna_radius_meters
		);
	double	random_force = Brownian_force_equivalent(
		node_separation_meters,
		temperature_kelvin,
		viscosity_Pascal_seconds,
		time_step_seconds
		);
	double	mass_damping = mass_damping_equivalent(
		viscosity_Pascal_seconds,
		effective_damping_radius,
		mass_kg);
	double	mass_radius = collision_radius_factor * (node_separation_meters / 2.0);
	double  collision_spring_constant = spring_constant * collision_force_factor;

	// Figure out where to put the output file.  Open it if needed.
	FILE *out = stdout;
	if (outfile_name != NULL) {
		out = fopen(outfile_name, "wb");
		if (out == NULL) {
			perror("Could not open output file");
			return -1;
		}
	}

	// Print out the header information and general parameters
	// for the simulation.  This includes medatadata lines and then
	// the beginning of the structure with its parameters
	fprintf(out, "meta temperature_Celsius %lg\n", temperature_Celsius);
	fprintf(out, "meta viscosity_centiPoise %lg\n", viscosity_centiPoise);
	fprintf(out, "meta effective_damping_radius %lg\n", effective_damping_radius);
	fprintf(out, "meta dna_modulus_gigaPascal %lg\n", modulus_gigaPascal);
	fprintf(out, "meta dna_radius_nanometers %lg\n", dna_radius_nanometers);
	fprintf(out, "meta damping_radius_factor %lg\n", damping_radius_factor);
	fprintf(out, "structure {\n");
	fprintf(out, "  random_force %lg\n", random_force);
	fprintf(out, "  mass_damping %lg\n", mass_damping);
	fprintf(out, "  mass_radius %lg\n", mass_radius);
	fprintf(out, "  time_step %lg\n", time_step_seconds);
	fprintf(out, "  collision_spring_constant %lg\n", collision_spring_constant);
	fprintf(out, "  spring_damping_factor %lg\n", spring_damping_factor);
	fprintf(out, "  random_number_seed %d\n", random_number_seed);
	fprintf(out, "  color %d\n", 1);

	// Put the masses into the system.  Attach a spring between each
	// pair of masses.  Attach a hinge between each triplet of
	// masses.  Stop when we get more than a fraction of the mass-
	// separation beyond the requested length.
	//i = 0;
	//double x;
	//double y = 0.0;
	//double epsilon = 0;
	//int array_length = (int)(chain_length_meters / node_separation_meters);
	//POINT *numbers = new POINT[array_length];
	//double xCenterAdjust;
	//double yCenterAdjust;
	//double angleOfRotation;
	//int colorNumber = 1;
	//double my_mass = mass_kg;

	//for (x = 0; x < chain_length_meters + epsilon; x += node_separation_meters, i++) {

	//	if (i == 0) {
	//		my_mass = 1000000;
	//	}

	//	//store the original line for later
	//	numbers[i][0] = x;
	//	numbers[i][1] = y;

	//	//make a 45 degree rotation about the center
	//	xCenterAdjust = x - chain_length_meters / 2.0;
	//	yCenterAdjust = y - chain_length_meters / 2.0;
	//	angleOfRotation = 45;
	//	double xPrime = (xCenterAdjust*cos(angleOfRotation) - yCenterAdjust * sin(angleOfRotation)) - .2e - 6;
	//	double yPrime = (xCenterAdjust*sin(angleOfRotation) + yCenterAdjust * cos(angleOfRotation)) + .2e - 6;
	//	fprintf(out, "  mass %u\t%g\t%g %g 0 %d\n", i, my_mass, xPrime, yPrime, colorNumber);

	//	if (i >= 1) {
	//		fprintf(out, "  spring %u %u %lg %lg\n", i - 1, i,
	//			node_separation_meters, spring_constant);
	//	}
	//	if (i >= 2) {
	//		fprintf(out, "  hinge %u %u %u %lg\n", i - 2, i - 1, i,
	//			hinge_constant);
	//	}
	//	if (i == 0) {
	//		my_mass = mass_kg;
	//	}
	//}

	//int j;
	//int first_mass = i;
	//double z;
	//colorNumber = colorNumber + 1;
	//for (j = 0; j < array_length; j++, i++) {
	//	if (j == 0) {
	//		my_mass = 1000000;
	//	}

	//	z = .01e - 6;
	//	x = numbers[j][0];
	//	y = numbers[j][1];
	//	xCenterAdjust = x - chain_length_meters / 2.0;
	//	yCenterAdjust = y - chain_length_meters / 2.0;
	//	angleOfRotation = 90;

	//	double xPrime = (xCenterAdjust*cos(angleOfRotation) - yCenterAdjust * sin(angleOfRotation)) - .2e - 6;
	//	double yPrime = (xCenterAdjust*sin(angleOfRotation) + yCenterAdjust * cos(angleOfRotation)) - .2e - 6;

	//	fprintf(out, "  mass %u\t%g\t%g %g %g %d\n", i, my_mass, xPrime, yPrime, z, colorNumber);
	//	if (i >= first_mass + 1) {
	//		fprintf(out, "  spring %u %u %lg %lg\n", i - 1, i,
	//			node_separation_meters, spring_constant);
	//	}
	//	if (i >= first_mass + 2) {
	//		fprintf(out, "  hinge %u %u %u %lg\n", i - 2, i - 1, i,
	//			hinge_constant);
	//	}

	//	if (j == 0) {
	//		my_mass = mass_kg;
	//	}
	//}

	// Build the chromatin loop:
	// Put the masses into the system.  Attach a spring between each
	// pair of masses.  Attach a hinge between each triplet of
	// masses.  Stop when we get more than a fraction of the mass-
	// separation beyond the requested length.
	int colorNumber = 1;
	double r;
	double loop_circumference = loop_radius_meters * 2 * acos(-1.0);
	double coh_circumference = cohesin_radius_meters * 2 * acos(-1.0);
	double epsilon = 0;
	i = 0;
	int first_mass = i;	// First mass in this particular ring.

	for (r = 0.0; r <= loop_circumference + epsilon - node_separation_meters; r += node_separation_meters, i++) {
		// Figure out where this mass is on the ring.  This is a ring
		// in the X-Y plane with the specified radius and mass spacing.
		double angle = (2 * acos(-1.0)) * r / loop_circumference;
		double x = sin(angle) * loop_radius_meters + .27e-6;
		double y = cos(angle) * loop_radius_meters;
		double z = 0.0;

		fprintf(out, "  mass %u\t%g\t%g %g %g %d\n", i, mass_kg, x, y, z, colorNumber);

		if (i >= first_mass + 1) {
			fprintf(out, "  spring %u %u %lg %lg\n", i - 1, i,
				node_separation_meters, spring_constant);
		}
		if (i >= first_mass + 2) {
			fprintf(out, "  hinge %u %u %u %lg\n", i - 2, i - 1, i,
				hinge_constant);
		}
	}

	// Hook the last mass to the first with a spring and a hinge.
	// Also hook a hinge to the first two and the last
	fprintf(out, "  spring %u %u %lg %lg\n", i - 1, first_mass,
		node_separation_meters, spring_constant);
	fprintf(out, "  hinge %u %u %u %lg\n", i - 2, i - 1, first_mass,
		hinge_constant);
	fprintf(out, "  hinge %u %u %u %lg\n", i - 1, first_mass, first_mass + 1,
		hinge_constant);

	// Now place cohesin rings in a circle around the loop.
	colorNumber = 5;
	for (int c = 0; c < num_rings; c++) {
		double angle_on_loop = c * (2*acos(-1.0)) / num_rings;
		double x_center = cos(angle_on_loop) * loop_radius_meters;
		double y_center = sin(angle_on_loop) * loop_radius_meters;
		first_mass = i; // First mass in this particular ring
		for (r = 0.0; r < coh_circumference + epsilon - node_separation_meters; r += node_separation_meters, i++) {
			// Figure out where this mass is on the ring.
			double angle = (2 * acos(-1.0)) * r / coh_circumference;
			double x = x_center + cos(angle) * cos(angle_on_loop) * cohesin_radius_meters + .27e-6;
			double y = y_center + cos(angle) * sin(angle_on_loop) * cohesin_radius_meters;
			double z = sin(angle) * cohesin_radius_meters;
			fprintf(out, "  mass %u\t%g\t%g %g %g %d\n", i, mass_kg, x, y, z, colorNumber);

			if (i >= first_mass + 1) {
				fprintf(out, "  spring %u %u %lg %lg\n", i - 1, i,
					node_separation_meters, spring_constant);
			}
			if (i >= first_mass + 2) {
				fprintf(out, "  hinge %u %u %u %lg\n", i - 2, i - 1, i,
					hinge_constant);
			}
		}
		// Hook the last mass to the first with a spring and a hinge.
		// Also hook a hinge to the first two and the last
		fprintf(out, "  spring %u %u %lg %lg\n", i - 1, first_mass,
			node_separation_meters, spring_constant);
		fprintf(out, "  hinge %u %u %u %lg\n", i - 2, i - 1, first_mass,
			hinge_constant);
		fprintf(out, "  hinge %u %u %u %lg\n", i - 1, first_mass, first_mass + 1,
			hinge_constant);
	}

	// Close off the structure.
	fprintf(out, "}\n");

	fclose(out);
	return 0;
}

