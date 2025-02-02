<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="file://///Ellenlargo/schoolbliz_vmuf/css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D2AE72">
<form>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" > 
      <td width="95%" height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FEE ADJUSTMENT TYPE PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td height="25" colspan="2"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a> 
        <%=strErrMsg%> 
        <%
if(!bolProceed)
	return;
%>
      </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Adjustment type name: <strong><%=request.getParameter("type_name0")%></strong> 
        <input name="type_name0" type="hidden" value="<%=request.getParameter("type_name0")%>"> 
      </td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="18%" height="25">Discount Type</td>
      <td width="80%" ><select name="select">
          <option>Tuition</option>
          <option>Miscellaneous</option>
          <option>Other Charges</option>
        </select>
        <select name="select2">
          <option>List of Misc Fees</option>
        </select>
        <select name="select3">
          <option>List of Other Charges Fees</option>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Exemptions/Discounts</td>
      <td > 
        <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(0);
else
	strTemp = WI.fillTextValue("discount");
%>
        <input name="discount" type="text" size="8" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="discount_unit">
          <option value="0">amount</option>
          <%
if(bolEditCalled)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("discount_unit");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>%</option>
          <%}else{%>
          <option value="1">%</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>unit</option>
          <%}else{%>
          <option value="2">unit</option>
          <%}%>
        </select> 
        <!--&lt;show this and the next row if no sub-type&gt;-->
      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="10">&nbsp;</td>
      <td width="18%" valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><font size="1"><font size="1"><img src="../../../images/save.gif" width="48" height="28">click 
        to save entries <font size="1"><img src="../../../images/cancel.gif">click 
        to cancel/clear entries </font></font></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
	</table>
  <table  bgcolor="#FFFFFF"width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="3"><div align="center"><strong>LIST OF EXEMPTIONS/DISCOUNTS 
          FOR THIS ADJUSTMENT TYPE </strong></div></td>
    </tr>
    <tr> 
      <td width="22%" height="25"><div align="center"><font size="1"><strong>DISCOUNT 
          TYPE</strong></font></div></td>
      <td width="45%" height="25"><div align="center"><font size="1"><strong>EXEMPTIONS/DISCOUNTS</strong></font></div></td>
      <td width="33%" height="25"><div align="center"><font size="1"></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><font size="1"><font size="1"><font size="1"><img src="../../../images/delete.gif"><font size="1"></font></font></font></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
