library i256;

use std::u256::U256;
use ::signed_integers::errors::Error;

/// The 256-bit signed integer type.
/// Represented as an underlying U256 value.
/// Actual value is underlying value minus 2 ^ 255
/// Max value is 2 ^ 255 - 1, min value is - 2 ^ 255
pub struct I256 {
    underlying: U256,
}

impl I256 {
    /// The underlying value that corresponds to zero signed value
    pub fn indent() -> U256 {
        U256 {
            a: 0,
            b: 1,
            c: 0,
            d: 0,
        }
    }
}

impl From<U256> for I256 {
    fn from(value: U256) -> Self {
        // as the minimal value of I256 is -I256::indent() (1 << 63) we should add I256::indent() (1 << 63) 
        let underlying = value + Self::indent();
        Self { underlying }
    }

    fn into(self) -> U256 {
        self.underlying - Self::indent()
    }
}

impl core::ops::Eq for I256 {
    fn eq(self, other: Self) -> bool {
        self.underlying == other.underlying
    }
}

impl core::ops::Ord for I256 {
    fn gt(self, other: Self) -> bool {
        self.underlying > other.underlying
    }

    fn lt(self, other: Self) -> bool {
        self.underlying < other.underlying
    }
}

impl I256 {
    /// The size of this type in bits.
    pub fn bits() -> u32 {
        128
    }

    /// Helper function to get a signed number from with an underlying
    pub fn from_uint(underlying: U256) -> Self {
        Self { underlying }
    }

    /// The largest value that can be represented by this integer type,
    pub fn max() -> Self {
        Self {
            underlying: U256::max(),
        }
    }

    /// The smallest value that can be represented by this integer type.
    pub fn min() -> Self {
        Self {
            underlying: U256::min(),
        }
    }

    /// Helper function to get a negative value of an unsigned number
    pub fn neg_from(value: U256) -> Self {
        Self {
            underlying: Self::indent() - value,
        }
    }

    /// Initializes a new, zeroed I256.
    pub fn new() -> Self {
        Self {
            underlying: Self::indent(),
        }
    }
}

impl core::ops::Add for I256 {
    /// Add a I256 to a I256. Panics on overflow.
    fn add(self, other: Self) -> Self {
        // subtract 1 << 63 to avoid double move
        Self::from(self.underlying - Self::indent() + other.underlying)
    }
}

impl core::ops::Divide for I256 {
    /// Divide a I256 by a I256. Panics if divisor is zero.
    fn divide(self, divisor: Self) -> Self {
        require(divisor != Self::new(), Error::ZeroDivisor);
        let mut res = Self::new();
        if (self.underlying > Self::indent()
            || self.underlying == Self::indent())
            && divisor.underlying > Self::indent()
        {
            res = Self::from((self.underlying - Self::indent()) / (divisor.underlying - Self::indent()) + Self::indent());
        } else if self.underlying < Self::indent()
            && divisor.underlying < Self::indent()
        {
            res = Self::from((Self::indent() - self.underlying) / (Self::indent() - divisor.underlying) + Self::indent());
        } else if (self.underlying > Self::indent()
            || self.underlying == Self::indent())
            && divisor.underlying < Self::indent()
        {
            res = Self::from(Self::indent() - (self.underlying - Self::indent()) / (Self::indent() - divisor.underlying));
        } else if self.underlying < Self::indent()
            && divisor.underlying > Self::indent()
        {
            res = Self::from(Self::indent() - (Self::indent() - self.underlying) / (divisor.underlying - Self::indent()));
        }
        res
    }
}

impl core::ops::Multiply for I256 {
    /// Multiply a I256 with a I256. Panics of overflow.
    fn multiply(self, other: Self) -> Self {
        let mut res = Self::new();
        if (self.underlying > Self::indent()
            || self.underlying == Self::indent())
            && (other.underlying > Self::indent()
            || other.underlying == Self::indent())
        {
            res = Self::from((self.underlying - Self::indent()) * (other.underlying - Self::indent()) + Self::indent());
        } else if self.underlying < Self::indent()
            && other.underlying < Self::indent()
        {
            res = Self::from((Self::indent() - self.underlying) * (Self::indent() - other.underlying) + Self::indent());
        } else if (self.underlying > Self::indent()
            || self.underlying == Self::indent())
            && other.underlying < Self::indent()
        {
            res = Self::from(Self::indent() - (self.underlying - Self::indent()) * (Self::indent() - other.underlying));
        } else if self.underlying < Self::indent()
            && (other.underlying > Self::indent()
            || other.underlying == Self::indent())
        {
            res = Self::from(Self::indent() - (other.underlying - Self::indent()) * (Self::indent() - self.underlying));
        }
        res
    }
}

impl core::ops::Subtract for I256 {
    /// Subtract a I256 from a I256. Panics of overflow.
    fn subtract(self, other: Self) -> Self {
        let mut res = Self::new();
        if self > other {
            // add 1 << 63 to avoid loosing the move
            res = Self::from(self.underlying - other.underlying + Self::indent());
        } else {
            // subtract from 1 << 63 as we are getting a negative value
            res = Self::from(Self::indent() - (other.underlying - self.underlying));
        }
        res
    }
}
