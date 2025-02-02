<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">

function AddRecord()
{
	alert("add record");
}

</script>
<body bgcolor="#663300">
<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EVALUATION SHEET MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <br> 
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td width="18%" height="25"><div align="left"><strong><font size="3">Criteria 
                for</font></strong></div></td>
            <td width="27%"> <select name="select2">
                <option>Teaching</option>
                <option>Non-teaching</option>
              </select> </td>
            <td width="55%"><strong><font size="3">Evaluation Sheet for Year 
              <input name="textfield6" type="text" size="4">
              to 
              <input name="textfield62" type="text" size="4">
              <img src="../../../images/refresh.gif" border="0"> </font></strong></td>
          </tr>
          <tr> 
            <td height="25"><strong>Available Items</strong></td>
            <td colspan="2"><select name="select3">
                <option>Teaching</option>
                <option>Non-teaching</option>
              </select></td>
          </tr>
          <tr> 
            <td height="25"><strong>Total Points </strong></td>
            <td colspan="2"><input name="textfield5" type="text" size="3"></td>
          </tr>
          <tr> 
            <td height="25"><strong>Item Order No.</strong></td>
            <td colspan="2"><select name="select5">
              </select></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="2"><input name="image2" type="image" onClick="AddRecord();" src="../../../images/add.gif"> 
              <font size="1">click to add new ITEM</font> <img src="../../../images/edit.gif" border="0"><font size="1" >click 
              to edit ITEM </font><img src="../../../images/delete.gif" border="0"><font size="1" >click 
              to delete selected ITEM</font></td>
          </tr>
          <tr> 
            <td height="25" colspan="3"><strong>Available Sub-ITEM under the ITEM</strong> 
              &lt;DISP SELECTED ITEM&gt;</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="2"><select name="select4">
                <option>Teaching</option>
                <option>Non-teaching</option>
              </select></td>
          </tr>
          <tr> 
            <td height="25"><strong>Sub-ITEM Points</strong></td>
            <td colspan="2"><input name="textfield4" type="text" size="3"></td>
          </tr>
          <tr> 
            <td height="25"><strong>Sub-ITEM Order No.</strong></td>
            <td colspan="2"><select name="select5">
              </select></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="2"><input name="image22" type="image" onClick="AddRecord();" src="../../../images/add.gif"> 
              <font size="1">click to add new SUB ITEM</font> <img src="../../../images/edit.gif" border="0"><font size="1" >click 
              to edit SUB ITEM </font><img src="../../../images/delete.gif" border="0"><font size="1" >click 
              to delete selected SUB ITEM</font></td>
          </tr>
          <tr bgcolor="#CCCCCC"> 
            <td height="25" colspan="3"><div align="center"><strong>LIST OF EVALUATION 
                SHEETS </strong></div></td>
          </tr>
          <tr> 
            <td height="25">SHEET YEAR</td>
            <td colspan="2">&nbsp;</td>
          </tr>
        </table>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr bgcolor="#CCCCCC"> 
            <td colspan="3"> <div align="center"><strong>VIEW ALL ITEM - SUB-ITEM 
                LISTING FOR &lt;.. print here the listing criteria..&gt;</strong></div></td>
          </tr>
          <tr> 
            <td colspan="3" bgcolor="ffffff">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="3" bgcolor="#CCCCCC"><strong><font color="#FF0000">Educational 
              Attainment</font></strong> <div align="center"></div></td>
          </tr>
          <tr> 
            <td width="5%">&nbsp;</td>
            <td width="79%">Highest Degree <font size="1">( Elementary, High School 
              &amp; Non Bachelor)</font></td>
            <td width="16%" align="center"><input name="textfield" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="5" maxlength="3"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Additional Degree <font size="1">( Bachelor, Masteral, Doctoral)</font></td>
            <td align="center"><input name="textfield2" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="5" maxlength="3"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Additional Credits/Units</td>
            <td align="center"><input name="textfield22" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="5" maxlength="3"></td>
          </tr>
          <tr> 
            <td colspan="3">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="3" bgcolor="#CCCCCC"><strong><font color="#FF0000">Length 
              of Service</font></strong></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Work of Service in VMUF</td>
            <td align="center"><input name="textfield2222" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="5" maxlength="3"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Work of Service outside VMUF</td>
            <td align="center"><input name="textfield22222" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="5" maxlength="3"></td>
          </tr>
          <tr> 
            <td colspan="3">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="3" bgcolor="#CCCCCC"><strong><font color="#FF0000">GENERAL 
              COMPETENCE</font></strong></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Working Competence</td>
            <td align="center"> <input name="textfield2222222" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="5" maxlength="3"> 
            </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Attitudinal Competence</td>
            <td align="center"> <input name="textfield22222222" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="5" maxlength="3"> 
            </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Personal Qualities</td>
            <td align="center"><input name="textfield222222222" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="5" maxlength="3"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td align="center">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td> <div align="right"><strong>GRAND TOTAL &nbsp;POINTS&nbsp;&nbsp;&nbsp;&nbsp;</strong></div></td>
            <td align="center"><input name="textfield2222222223" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="10" maxlength="3"></td>
          </tr>
          <tr bgcolor="#CCCCCC"> 
            <td colspan="3"><strong><font color="#FF0000">REMARKS / COMMENT</font></strong></td>
          </tr>
          <tr> 
            <td colspan="3"><div align="center"> 
                <textarea name="textarea" cols="62" rows="8"></textarea>
              </div></td>
          </tr>
          <tr> 
            <td colspan="3"><table width="73%" border="1" align="center" cellpadding="3" cellspacing="0">
                <tr> 
                  <td width="45%">Evaluator :<br> <select name="select">
                      <option value="1">Administrator</option>
                      <option value="2">Supervisor</option>
                    </select> <br> </td>
                  <td width="55%"> Date of Evaluation: <br> <input type="text" name="textfield3"></td>
                </tr>
              </table></td>
          </tr>
        </table>
        <hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
</form>
</body>
</html>

