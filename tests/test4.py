def bubble_sort(arr: list[int],n:int) ->list[int]:
    for i in range(n):
        for j in range(0, n):
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
    return arr


def binary_search(arr: list[int],n:int, target: int) -> int:
    left:int= 0
    right:int=n-1
    while left <= right:
        mid:int = (left + right) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1


def main():
    unsorted_list:list[int] = [64, 25, 12, 22, 11]
    print("Unsorted list:")
    print(unsorted_list)
    sorted_list:list[int] = bubble_sort(unsorted_list,5)
    print("Sorted list:")
    print(sorted_list)
    
    target:int = 22
    index:int = binary_search(sorted_list,5, target)
    if index != -1:
      print("Element found.")
    else:
      print("Elemet not found in the list.")

if __name__ == "__main__":
    main()
