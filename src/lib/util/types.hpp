#pragma once
#include <es3n1n/common/memory/address.hpp>

namespace types {
    template <class Ty, class... Types>
    inline constexpr bool is_any_of_v = std::disjunction_v<std::is_same<Ty, Types>...>;

    using rva_t = memory::address;

    struct range_t {
        rva_t start;
        rva_t end;

        [[nodiscard]] std::size_t size() const {
            return (end - start).as<std::size_t>();
        }
    };

    /// Used for static assertions
    template <typename = std::monostate> concept always_false_v = false;
} // namespace types
