' Project.spin
' (M Montgomery, A Blue, Z Lin)

CON                                                                             ' set clock speed
_clkmode = xtal1 + pll1x                                                        ' multiply base clock freq
_xinfreq = 5_000_000                                                            ' base clock freq (5 MHz)

OBJ                                                                             ' INCLUDE OTHER PROGRAMS
  lcd : "ObjectLCD"                                                             ' include objectlcd
  hyp : "ObjectSerial"                                                          ' include serial object
  mem : "ObjectMemory"                                                          ' include memory object


PUB MAIN | addr,data                                                            ' MAIN PROGRAM
  lcd.start                                                                       ' start lcd
  lcd.line1                                                                     ' move cursor to line 1
  lcd.str(string("Hello World"))

  dira[15]:=0                                                                     ' set mode pin to an input
  if ina[15]==1                                           ' ----------------------- store data if pin 15 is 3.3 V
    addr:=1                                                                       ' initialize address pointer to 1
    lcd.line2                                                                     ' move cursor to line 1
    lcd.str(string("Collecting Temp"))
    repeat                                                                        ' repeat forever (until unplugged)
      data:= MEASURE_TEMP (5,357)-100                                             ' call measure_temp
      mem.write(addr+1,0)                                                         ' store 0 in next memory addr
      mem.write(addr,data)                                                        ' store data at current memory addr
      addr:=addr+1                                                                ' increment address
      waitcnt(clkfreq*5+cnt)                                                      ' wait 5 seconds
  else                                                    ' ----------------------- else retrieve data (pin 15 is 0 V)
    hyp.start(31,30,9600)                                                         ' start hyperterminal print object
    lcd.line2                                                                     ' move cursor to line 1
    lcd.str(string("Download Temp"))
    addr:=1                                                                       ' initialize address pointer to 1
    data:=1                                                                       ' set value of data for 1st repeat
    hyp.crlf                                                                      ' print carriage and return line feed
    hyp.str(string("Stored Data..."))                                             ' print message string
    hyp.crlf                                                                      ' print carriage and return line feed
    repeat until data==0                                                          ' repeat until data = 0
      data:=mem.read(addr)                                                        ' read byte at memory addr
      hyp.dec(data)                                                               ' print data to hyperterminal
      hyp.crlf                                                                    ' print carrage return and line feed
      addr:=addr+1                                                                ' increment address pointer
      lcd.line2
      lcd.dec(data)

PUB MEASURE_TEMP (pin, cal) | count                                             ' MEASURE TEMPERATURE
  count := 0                                                                    ' initialize counter to zero
  outa[pin] := 0                                                                ' set pin to 0
  dira[pin] := 1                                                                ' make pin an output
  waitcnt (clkfreq/1000+cnt)                                                    ' wait cap discharge
  dira[pin] := 0                                                                ' make pin an input
  count := cnt                                                                  ' store count value
  waitpeq(|<pin,|<pin,0)                                                        ' wait for pin to go high
  count := ||(cnt-count)-11                                                     ' clock cycles-delay
  return clkfreq*10/count*cal/10000                                             ' convert count to K

PUB SERVO (pin,pos)                                                             ' CONTROL SERVO ON PIN (5=<POS=<15)
  dira[pin]:=1                                                                  ' set pin to output
  repeat 30                                                                     ' repeat for 30 pulses
    outa[pin]:=1                                                                ' turn pin on
    waitcnt(clkfreq*pos/10000+cnt)                                              ' wait during on period
    outa[pin]:=0                                                                ' turn pin off
    waitcnt(clkfreq*20/1000+cnt)                                                ' wait 20 msec for off period

PUB LED
  dira[0]:=1                                                                    '  pin 0 on

  repeat                                                                        ' loops 100 times
    outa[0] := 1                                                                ' pin 0 on
    waitcnt(clkfreq*8/1000 + cnt)                                               ' pin 0 on 4/5 of a second                      ' 80% duty cycle
    outa[0] := 0                                                                ' pin 0 off
    waitcnt(clkfreq*2/1000 + cnt)                                               ' pin 0 on 1/5 of a second