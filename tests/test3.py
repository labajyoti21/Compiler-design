def max_sum_subarray(arr:list[int])->int:
    max_sum:int = 1000000000000000
    current_sum:int = 0
    start_index:int = 0
    end_index:int = 0
    temp_start_index:int = 0
    n:int=len(arr)
    for i in range(n):
        current_sum += i
        if current_sum > max_sum:
            max_sum = current_sum
            start_index = temp_start_index
            end_index = i
        if current_sum < 0:
            current_sum = 0
            temp_start_index = i + 1
    
    return max_sum


def main():
    arr:list[int] = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
    max_sum:int = max_sum_subarray(arr)


if __name__ == "__main__":
    main()
