<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function Punish() {
	location = "./disc_agreement_p2.jsp?stud_id="+document.form_.stud_id.value+"&sy_from="+
	document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester.value;
}
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%
	String strTemp = request.getParameter("stud_id");
	if(strTemp == null) strTemp = "";
%>
<form action="./disc_agreement_p1.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>::::
          STUDENT PERSONAL INFO PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="4">&nbsp;<font size="3" color="red"><strong><%=WI.getStrValue(WI.fillTextValue("passed_message"))%></font></font></td>
    </tr>
    <tr>
      <td height="25" width="25%">&nbsp;</td>
      <td >School year</td>
      <td> 
      <%strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");%> 
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
        <%strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");%> 
	 <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
      </td>
      <td>Term: 
       <%strTemp = WI.fillTextValue("semester");
       if(strTemp.length() ==0 )
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");%>
      <select name="semester" style="font-size:11px">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected=>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
        </td>
    </tr>
    <tr >
      <td height="25"></td>
      <td width="12%" height="25">Student ID</td>
      <td width="23%">
      <%strTemp = WI.fillTextValue("stud_id");%>
      <input type="text" name="stud_id" size="20" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="40%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
    <tr >
      <td height="25"></td>
      <td height="25">&nbsp;</td>
      <td colspan="2"><a href="javascript:Punish();" >
      <img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="86%" height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="passed_message">
</form>
</body>
</html>
