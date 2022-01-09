#ifndef VIEW_PTR_HXX
#define VIEW_PTR_HXX

#include "ptr_concept.hxx"

template <typename T>
class view_ptr {
public:
	typedef T element_type;

	template <ptr_t<T> U>
	view_ptr(U ptr);
};

#endif
