
#include <cstddef>
#include <gtest/gtest.h>

int myFunction() { return 0; };

TEST(myFunction, intOutput) { EXPECT_EQ(myFunction(), 0); }
