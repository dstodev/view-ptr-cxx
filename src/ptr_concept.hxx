#ifndef PTR_CONCEPT_HXX
#define PTR_CONCEPT_HXX

#include <concepts>
#include <memory>

template <typename T, typename Y>
concept ptr_t = requires(T type) {
	{ type.get() } -> std::same_as<Y*>;
};

#endif
