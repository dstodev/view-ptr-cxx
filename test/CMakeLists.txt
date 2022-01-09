find_package(HelpGTestLibrary REQUIRED)

help_gtest_library(view_ptr
	SOURCES
		test_ptr_concept.cxx
		test_view_ptr.cxx
)
