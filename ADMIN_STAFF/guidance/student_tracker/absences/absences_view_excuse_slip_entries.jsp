<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D2AE72">
<form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EXCUSE SLIP ENTRIES SUMMARY 
          PAGE::::</strong></font></div></td>
    </tr>
	</table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
     <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student ID</td>
      <td height="25"><%strTemp = WI.fillTextValue("stud_id");%>
     <input name="stud_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      <a href="javascript:StudSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for student ID</font></td>
      <td height="25"><a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
 <%if (vBasicInfo!= null && vBasicInfo.size()>0){
	strTemp =(String)vBasicInfo.elementAt(19);
    %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Student Name :<strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td height="25">Gender : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"Not defined")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Brithdate : <strong><%=WI.getStrValue(strTemp, "Undefined")%></strong></td>
      <td height="25">Age :<strong><%if (strTemp !=null && strTemp.length()>0){%><%=CommonUtil.calculateAGEDatePicker(strTemp)%><%}else{%>Undefined<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Course/Major : <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Year Level : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
    </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr> 
      <td width="2%"><p>&nbsp;</p></td>
      <td width="17%">School Year</td>
      <td width="81%" colspan="2"> <%strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
/
<select name="semester">
  <%strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}if(strTemp.compareTo("1") ==0){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.compareTo("2") == 0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") == 0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}%>
</select></td>
    </tr>
 <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="17%">Date Absent : </td>
      <td height="25" width="20%">
        <%
       if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		else		
			strTemp = WI.fillTextValue("date_absent_fr");
		 if (strTemp == null || strTemp.length()==0)
        	  	strTemp = WI.getTodaysDate(1);%>
		<input name="date_absent_fr" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_absent_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td height="25" width="50%"><%
       if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(2),"");
		else		
			strTemp = WI.fillTextValue("date_absent_to");%>
		<input name="date_absent_to" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_absent_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#D8D569"> 
      <td height="25" colspan="4"><div align="center">EXCUSE SLIP FORM ENTRIES 
          FOR <strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></div></td>
    </tr>
    <tr>
	  <td width="30%"><div align="center"><strong><font size="1">SY/TERM</font></strong></div></td>
      <td width="30%"><div align="center"><strong><font size="1">DATE ABSENT</font></strong></div></td>
      <td width="30%" height="25"><div align="center"><font size="1"><strong><strong>REASON(S)</strong></strong></font></div></td>
      <td width="10%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td >&nbsp;</td>
      <td><img src="../../../../images/edit.gif"></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="3%" height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#A49A6A"> 
    <td height="25">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
