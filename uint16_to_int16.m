function Y = uint16_to_int16 (X)
    isNegative = int16(bitget(X,16));
    Y = int16(bitset(X,16,0)) + (-2^15)*isNegative;
end