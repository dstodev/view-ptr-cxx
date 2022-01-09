#[[
	Parses function arguments past the last required function argument.

	Helps parse arguments by abstracting technical details of CMake's builtin (>= CMake 3.5)
	cmake_parse_arguments(). Autmatically uses the more intuitive but harder to use PARSE_ARGV
	variant of cmake_parse_arguments() to enable passing lists as one-value keyword arguments.

	Parameters
	----------
	prefix
		String prefixed to each parsed argument variable delimited by an underscore,
		e.g. myprefix_MYOPTION.

	options
		List of option flags to parse for, e.g. "DO_THING;DO_EXTRA_THING"
		For more information, view docs for cmake_parse_arguments(... <options> ...)

	one_value_keywords
		List of keywords to parse for which expect a single value, e.g. "MY_TARGET;MY_LIB_TYPE"
		Supports stringified lists as the single value.
		For more information, view docs for cmake_parse_arguments(... <one_value_keywords> ...)

	multi_value_keywords
		List of keywords to parse for which expect multiple values, e.g. "MY_EXTRA_CXX_FLAGS"
		For more information, view docs for cmake_parse_arguments(... <multi_value_keywords> ...)

	Example
	-------
	find_package(HelpParseArguments REQUIRED)

	function(my_function target)
		help_parse_arguments(args "PRINT_VALUES" "VALUE1;VALUE2" "OTHER_VALUES")

		if (args_PRINT_VALUES)
			message("Value 1: ${args_VALUE1}")
			message("Value 2: ${args_VALUE2}")
			foreach (val IN LISTS args_OTHER_VALUES)
				message("Other value: ${val}")
			endforeach ()
		endif ()
	endfunction()

	my_function(some_target PRINT_VALUES VALUE1 a b VALUE2 "c;d" OTHER_VALUES e f g)

	#[=[
	Output:
		[cmake] Value 1: a
		[cmake] Value 2: c;d
		[cmake] Other value: e
		[cmake] Other value: f
		[cmake] Other value: g
	]=]
]]
macro(help_parse_arguments prefix options one_value_keywords multi_value_keywords)
	# Variables are prefixed with _ to avoid name collisions in parent scope

	list(LENGTH ARGV _num_argv)  # Number of arguments passed to the calling function
	list(LENGTH ARGN _num_argn)  # Number of arguments past the last expected parameter
	math(EXPR _expected_args_offset "${_num_argv} - ${_num_argn}")

	# Skip past the expected args.
	cmake_parse_arguments(PARSE_ARGV "${_expected_args_offset}" "${prefix}"
		"${options}"
		"${one_value_keywords}"
		"${multi_value_keywords}"
	)

	############################################################################################

	#[[
		# Learned while implementing this macro:
		# To get one of the calling function's special variables e.g. ARGC:

		set(_caller_argc_hack "ARGC")
		set(_caller_argc "${${_caller_argc_hack}}")
		message("Macro's ARGC:  ${ARGC}")
		message("Caller's ARGC: ${_caller_argc}")

		# This works because in a macro, ${ARGC} will be text-replaced (similar to the C/C++
		# preprocessor), but ${${variable_expanding_to_ARGC}} will not be text-replaced, so
		# the resulting ${ARGC} variable is evaluated within the context of the calling function
		# instead of this macro.
	]]
endmacro()

#[[
	TODO
]]
function(help_print_parsed_arguments _prefix)
	# Get all variables first to avoid inclusion of variables used in this function.
	# Variables are prefixed with _ to reduce risk that variables to print have the same name
	# as variables used in this function. Function parameters are also considered variables.
	get_cmake_property(_all_variables VARIABLES)

	help_parse_arguments(_params "" "VERBOSITY" "")

	# Match all variables with prefix
	string(REGEX MATCHALL "(^|;)${_prefix}_[A-Za-z0-9_]*" _prefixed_variables "${_all_variables}")

	# Remove leading & duplicate semicolons
	string(REGEX REPLACE "(^|;);" "\\1" _prefixed_variables "${_prefixed_variables}")

	foreach (_var IN LISTS _prefixed_variables)
		message(${_params_VERBOSITY} "${_var}: ${${_var}}")
	endforeach ()
endfunction()
