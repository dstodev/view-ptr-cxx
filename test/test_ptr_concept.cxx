#include <gtest/gtest.h>

#include <memory>

#include <ptr_concept.hxx>

template <typename T = void>
static const char* Select(T&) {
	return "fail";
}

template <ptr_t<int> T>
static const char* Select(T&) {
	return "pass";
}

struct empty_t {};
struct get_t {
	void get();
};
struct all_t {
	int* get();
};

TEST(ViewPtr, helper_select_fails_empty_struct) {
	empty_t t;

	ASSERT_STREQ("fail", Select(t));
}

TEST(ViewPtr, helper_select_fails_struct_with_get_but_incorrect_return) {
	get_t t;

	ASSERT_STREQ("fail", Select(t));
}

TEST(ViewPtr, helper_select_passes_struct_with_get_returning_intptr) {
	all_t t;

	ASSERT_STREQ("pass", Select(t));
}


TEST(ViewPtr, selects_unique_ptr) {
	std::unique_ptr<int> ptr;

	ASSERT_STREQ("pass", Select(ptr));
}

TEST(ViewPtr, selects_shared_ptr) {
	std::shared_ptr<int> ptr;

	ASSERT_STREQ("pass", Select(ptr));
}
