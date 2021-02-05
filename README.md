# TF2-sourcemode-plugins
Some Plugins i made

***- kamikazeNec.sp - Adds "!kamikaze" command to Freak Fortress 2.*** 

      > "!kamikaze" changes classes of alive RED players to Demoman and gives them a Caber which kills the User on Hit. 
   
      > "!kamikaze true" Revives the RED team, changes them to Demoman and gives them a Caber which kills the User on Hit.
   
      > Damage done to Enemies uses Damagescaling (FF2BossHealth\*FF2BossLives/PlayersOnRED), although can be changed to use Attributes if specific lines are Commented/Uncommented

***- disguiseEFfects.sp - Adds Effects for different Disguises.***

      > Detects Disguises and gives Effects based on The Disguise.
      
***- mmHealthRefill.sp  - Adds Smooth Health Refill to Freak Fortress 2***
      
      > If damage is originally supposed to kill you (The Boss), this plugin sets your HP to 1 and Smoothly Regenerates it back to full health. Basically a second life!
      > arg1 Equals to the Number of Lives. 1 being 0 Refills, 2 being 1 Refill, etc.
      > arg2 Equals to the Level of Impairment. 0 = No Attacking during Refill, 1 = Complete Movement a. Attacking Freeze, 3 = No Impairment
