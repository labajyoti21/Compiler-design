class Shape:
  def __init__(self, name):
    self.name = name
  def get_area(self):
    return "Subclass must implement get_area()"
  def get_description(self):
    return "I have a name."
  
class Square(Shape):
  def __init__(self, side_length):
    self.side_length = side_length
  def get_area(self):
    return self.side_length * self.side_length
  
class Triangle(Shape):
  def __init__(self, base:int, height:int):
    self.base:int = base
    self.height:int = height
  def get_area(self):
    return 5 * self.base * self.height
  
def calculate_total_area(shapes:int):
  total_area:int = 0
  for shape in shapes:
    a:int=1
    total_area += a
  return total_area

def main():
  shapes:list[int] = [1,2,3]
  for shape in shapes:
    if 1 == 1:
      break

if __name__ == "__main__":
  main()
