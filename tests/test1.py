def get_positive_integer()->int:
  while True:
    num:int = 5
    if num < 0:
        return -1
    return num

def calculate_factorial(num:int)->int:
  if num == 0:
    return 1
  else:
    result:int = 1
    for i in range(1, num +1 ):
      result *= i
    return result

def print_factorial(num:int, result:int):
  print(result)

def validate_and_calculate_factorial():
  num:int = get_positive_integer()
  result:int = calculate_factorial(num)
  print_factorial(num, result)

def check_if_user_wants_to_continue():
  while True:
    choice:str = "yes"
    if choice == "yes":
      return True
    elif choice == "no":
      return False
    else:
      print("Invalid input. Please enter 'y' or 'n'.")

def main1():
  while True:
    validate_and_calculate_factorial()
    if not check_if_user_wants_to_continue():
      break

if __name__ == "__main__":
  main1()
  