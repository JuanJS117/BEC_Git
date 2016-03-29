      
         Implicit none
         Integer, Parameter :: Nats = 200
         Real*8  :: q, qAt(Nats), rAt(Nats), qT
         Integer :: i, iRTF, iPDB
         Character(len=25) lineRTF
         Character(len=40) inpRTF, inpPDB, outPQR
         Character(len=80) linePDB

         Write(*,'(5x,a$)') 'SwissParam PDB input file name  ?  '
         Read(*,'(a)') inpPDB
         Write(*,'(5x,a$)') 'SwissParam RTF input file name  ?  '
         Read(*,'(a)') inpRTF 
         Write(*,'(5x,a$)') '           PQR output file name ?  '
         Read(*,'(a)') outPQR
         Open(3,file=inpRTF)
         Open(4,file=inpPDB)
         Open(8,file=outPQR)
         
         Write(8,'(a)') 'REMARK  PQR FILE GENERATED FROM SwissParam DATA WITH rtf2pqr'
         Write(8,'(a)') 'REMARK '
         Write(8,'(a)') 'REMARK '
         
! Read atom types and atomic charges in RTF file
! Assign atom radii derived from CHARMM PQR values in proteins 

         i = 1
         Do
            Read(3,'(a)') lineRTF 
            If( lineRTF(1:4) == 'ATOM') then
               read(lineRTF,'(14x,f8.4)') q
               qAt(i) = q
               Call AssignRadius(lineRTF,rAt(i))
               i = i+1
               Cycle
            ElseIf( lineRTF(1:4) == 'BOND') then
               Exit
            End If
         End Do
         iRTF = i
         
! Read atom coordinates in PDB file and write output PQR file

         i = 1
         Do
            Read(4,'(a)') linePDB 
            If( linePDB(1:4) == 'ATOM') then
               Write(8,'(a54,f8.4,f7.4)') linePDB(1:54),qAt(i),rAt(i)
               i = i+1
               Cycle
            ElseIf( linePDB(1:3) == 'TER') then
               Exit
            End If
         End Do
         iPDB = i
         
         If( iPDB /= iRTF ) Write(*,'(/5x,a)') 'ERROR: Different number of atoms in PDB and RTF files'
         
         Write(8,'(a)') 'END '
         Write(8,*)
         qT = 0.d0
         Do i = 1,iPDB
            qT = qT + qAt(i)
         End Do
         Write(*,*)
         Write(*,'(5x,a,f8.4)') 'Total charge = ',qT
         End

! -----------------------------------------------------------------------
! Assign atom radii derived from CHARMM PQR values in proteins 
! C =  1.9924 (AROMATIC: CB)  2.0000 (C=C,C=O; C=)    2.1750 (C sp3: CR)
! O =  1.7000 (CARBONYL: O=)  1.7700 (HYDROXYL,ETHER: OR)
! N =  1.8500
! H =  0.2245 (HYDROXYL, AMINE: HO,HN)  1.3500 (-C: HC)
! -----------------------------------------------------------------------

         Subroutine AssignRadius(line,rA)
         Implicit none
         Real*8  :: rA
         Character(len=2)  Type
         Character(len=25) line
         If( line(11:11) == 'N' ) then
            rA = 1.8500d0
            Return
         End If         
         Type = line(11:12)
         Select Case(Type)
         Case( 'CB' )
            rA = 1.9924d0
         Case( 'CR' )
            rA = 2.1750d0
         Case( 'C=' )
            rA = 2.0000d0
         Case( 'O=' )
            rA = 1.7000d0
         Case( 'OR' )
            rA = 1.7700d0
         Case( 'HN' )
            rA = 0.2245d0
         Case( 'HO' )
            rA = 0.2245d0
         Case( 'HC' )
            rA = 1.3500d0
         End Select
         Return
         End         
