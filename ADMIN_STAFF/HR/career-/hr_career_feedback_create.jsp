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
          CAREER FEEDBACK MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <br> 
         <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td height="25" colspan="2">NOTE: 
                Select &lt;ALL&gt; in AVAILABLE MAIN ITEM to view complete career 
                feedback sheet</td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><img src="../../../images/refresh.gif">
			<font size="1">Click to refresh the page.</font></td>
          </tr>
		</table>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td height="25" colspan="2"><strong><font color="#0000FF" size="1">AVAILABLE 
              MAIN ITEMS</font></strong></td>
          </tr>
          <tr> 
            <td width="3%" height="25"><strong></strong></td>
            <td width="97%">
			<select name="select3">
              </select></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td><textarea name="textarea2" cols="40" rows="2"></textarea></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td><input name="image2" type="image" onClick="AddRecord();" src="../../../images/add.gif"> 
              <font size="1">click to add new ITEM</font> <img src="../../../images/edit.gif" border="0"><font size="1" >click 
              to edit ITEM </font><img src="../../../images/delete.gif" border="0"><font size="1" >click 
              to delete selected ITEM</font></td>
          </tr>
          <tr> 
            <td height="31" colspan="2"><strong><font color="#0000FF" size="1">AVAILABLE 
              SUB ITEM UNDER MAIN ITEM &lt;$ITEM&gt;</font></strong></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td><select name="select4">
              </select></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td>
<input type="checkbox" name="checkbox" value="checkbox">
              Tick if Sub ITEM is descriptive (for descriptive items input is 
              a text area)</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td><textarea name="textarea3" cols="40" rows="2"></textarea></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td><input name="image22" type="image" onClick="AddRecord();" src="../../../images/add.gif"> 
              <font size="1">click to add new SUB ITEM</font> <img src="../../../images/edit.gif" border="0"><font size="1" >click 
              to edit SUB ITEM </font><img src="../../../images/delete.gif" border="0"><font size="1" >click 
              to delete selected SUB ITEM</font></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr bgcolor="#CCCCCC"> 
            <td colspan="3"> <div align="center"><strong><font size="1">VIEW &lt;ALL/ITEM 
                NAME&gt; ITEM - SUB-ITEM LISTING</font></strong></div></td>
          </tr>
          <tr> 
            <td colspan="3" bgcolor="ffffff">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="3" bgcolor="#CCCCCC"><font color="#FF0000"><strong>HEAD 
              COMPETENCIES</strong></font> <div align="center"></div></td>
          </tr>
          <tr> 
            <td width="5%">&nbsp;</td>
            <td width="88%">Supports others to accomplish educational objectives.</td>
            <td width="7%" align="center"><select 
                   name=rate1>
                <option value=0 selected>N/C</option>
                <option 
                    value=1>1</option>
                <option value=2>2</option>
                <option 
                    value=3>3</option>
                <option value=4>4</option>
                <option 
                    value=5>5</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Expects, communicates, and encourages quality performance from 
              others.</td>
            <td align="center"><select 
                   name=select>
                <option value=0 selected>N/C</option>
                <option 
                    value=1>1</option>
                <option value=2>2</option>
                <option 
                    value=3>3</option>
                <option value=4>4</option>
                <option 
                    value=5>5</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Recognizes and rewards good ideas from others.</td>
            <td align="center"><select
                   name=select2>
                <option value=0 selected>N/C</option>
                <option 
                    value=1>1</option>
                <option value=2>2</option>
                <option 
                    value=3>3</option>
                <option value=4>4</option>
                <option 
                    value=5>5</option>
              </select></td>
          </tr>
           <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td align="center">&nbsp;</td>
          </tr>
         <tr> 
            <td>&nbsp;</td>
            <td>What traits of your superiors’s style do you feel are most effective? 
              <br> <TEXTAREA id=textarea  name=ans1 rows=3 cols=50></TEXTAREA> 
            </td>
            <td align="center">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td> What traits of your supervisor’s style do you feel are least 
              effective?<BR> <TEXTAREA id=textarea2  name=ans2 rows=3 cols=50></TEXTAREA> 
            </td>
            <td align="center">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td align="center">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td align="center">&nbsp;</td>
          </tr>
        </table>
        
      </td>
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

