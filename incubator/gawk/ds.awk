awk -F',' 'fn && FILENAME != fn{ 
  print "before sub:", FILENAME, fn
  sub(".*/", "", fn);
  print "after sub:", fn, sprintf("%.2f", sum/n); sum = 0
}
{ print "in 2nd stat, before sum += $2:", FILENAME, fn, FNR, sum, $2
  sum += $2; n = FNR; fn = FILENAME
  print "in 2nd stat, after sum += $2:", sum
}
END{ 
    sub(".*/", "", fn);
    print fn, sprintf("%.2f", sum/n)
}' *.dat
