inFile = File.new("hygxyz.csv", "r")
outFile = File.new("processed.csv", "w")

x = 0;
y = 0;
z = 0;
numStars = 0;

inFile.each {
  |theLine|
  
  fields = theLine.split(",")  
  # interestingFields = fields[6..6] + fields[17..19];
    
  begin
    absMag = Float(fields[14])  # Si no es un número, saltará excepción y pasamos al siguiente
  
    if (absMag > 5)
       posFields = fields[17..19];
    
      resultLine = String.new(posFields[0])
      
      # posFields[1] = "0"
            
      for c in 1...posFields.length 
        resultLine << "," << posFields[c] 
      end
      
      x = x + Float(posFields[0])
      y = y + Float(posFields[1])
      z = z + Float(posFields[2])
      
      numStars = numStars + 1
      
      outFile.puts resultLine    
    end
  rescue
  end
}

x = x / numStars
y = y / numStars
z = z / numStars

puts "NumStars: %d, Galaxy Center: %f %f %f " % [numStars, x, y, z]

inFile.close
outFile.close