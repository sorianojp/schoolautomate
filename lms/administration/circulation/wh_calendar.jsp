<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;	
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function ViewCal() {//alert("I am in");
	location = "./holiday_calendar.jsp?year_="+
				document.form_.year_[document.form_.year_.selectedIndex].value;
}
</script>

<%@ page language="java" import="utility.*,lms.MgmtCirculation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Administration-CIRCULATION".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Administration".toUpperCase()),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-CIRCULATION","wh_calendar.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

	MgmtCirculation mgmtBP = new MgmtCirculation();
	Vector vRetResult = null;
	
    Vector vDays  = null;
    Vector vMonth = null;
    Vector vDates = null;
	vRetResult    = mgmtBP.operateOnWHCalendar(dbOP, request);	
	strErrMsg = mgmtBP.getErrMsg();
	
	if(vRetResult != null && vRetResult.size() > 0) {
		vDays  = (Vector)vRetResult.remove(0);
		if(vRetResult.size() > 0)
			vMonth = (Vector)vRetResult.remove(0);
		if(vRetResult.size() > 0)
			vDates = (Vector)vRetResult.remove(0);		
	}
%>

<body bgcolor="#DEC9CC">
<form action="./wh_calendar.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION MANAGEMENTs - FINE IMPLEMENTATION SETUP PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;<font size="3" color="#FF0000"><strong> <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font> 
      </td>
    </tr>
<!--	  
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%">SY/TERM</td>
      <td width="31%">
<%
strTemp = WI.fillTextValue("sy_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("stud_ledg","sy_from","sy_to")'>
        - 
<%
strTemp = WI.fillTextValue("sy_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
		<option value="">ALL</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select></td>
      <td width="52%"><a href="fines.htm"><img src="../../images/form_proceed.gif"border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1" color="#00CCFF"></td>
    </tr>
-->  </table> 
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%" height="22" class="thinborderBOTTOM">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM"><strong>Days listed holiday </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><label>
<%
strTemp = null;
if(vDays != null) 
	strTemp = (String)vDays.remove(0);
if(WI.getStrValue(strTemp).equals("0")){
	strErrMsg = " checked";
	strTemp = null;
}
else	
	strErrMsg = "";
%>
        <input type="checkbox" name="1_" value="0"<%=strErrMsg%>>Sunday 
<%
if(vDays != null && strTemp == null && vDays.size() > 0) 
	strTemp = (String)vDays.remove(0);
if(WI.getStrValue(strTemp).equals("1")){
	strErrMsg = " checked";
	strTemp = null;
}
else	
	strErrMsg = "";
%>
<input type="checkbox" name="2_" value="1"<%=strErrMsg%>>Monday 
<%
if(vDays != null && strTemp == null && vDays.size() > 0) 
	strTemp = (String)vDays.remove(0);
if(WI.getStrValue(strTemp).equals("2")){
	strErrMsg = " checked";
	strTemp = null;
}
else	
	strErrMsg = "";
%><input type="checkbox" name="3_" value="2"<%=strErrMsg%>>Tuesday 
<%
if(vDays != null && strTemp == null && vDays.size() > 0) 
	strTemp = (String)vDays.remove(0);
if(WI.getStrValue(strTemp).equals("3")){
	strErrMsg = " checked";
	strTemp = null;
}
else	
	strErrMsg = "";
%><input type="checkbox" name="4_" value="3"<%=strErrMsg%>>Wednesday
<%
if(vDays != null && strTemp == null && vDays.size() > 0) 
	strTemp = (String)vDays.remove(0);
if(WI.getStrValue(strTemp).equals("4")){
	strErrMsg = " checked";
	strTemp = null;
}
else	
	strErrMsg = "";
%><input type="checkbox" name="5_" value="4"<%=strErrMsg%>>Thursday 
<%
if(vDays != null && strTemp == null && vDays.size() > 0) 
	strTemp = (String)vDays.remove(0);
if(WI.getStrValue(strTemp).equals("5")){
	strErrMsg = " checked";
	strTemp = null;
}
else	
	strErrMsg = "";
%><input type="checkbox" name="6_" value="5"<%=strErrMsg%>>Friday 
<%
if(vDays != null && strTemp == null && vDays.size() > 0) 
	strTemp = (String)vDays.remove(0);
if(WI.getStrValue(strTemp).equals("6")){
	strErrMsg = " checked";
	strTemp = null;
}
else	
	strErrMsg = "";
%><input type="checkbox" name="7_" value="6"<%=strErrMsg%>>Saturday <br>

      <font size="1"><a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a>Click to save changes. </font></label></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM"><strong>Dates listed holiday </strong></td>
    </tr>
    <tr>
      <td height="10"></td>
      <td colspan="2"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="31%" valign="top">
	  <select name="month_">
        <%=dbOP.loadComboMonth(WI.fillTextValue("month_"))%>
      </select>
	  <select name="day_">
<%
int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("day_"),"1"));
for(int i = 1; i < 32; ++i){
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
	%><option value="<%=i%>"><%=i%></option>
<%}%>
	  </select><br>
	  <a href='javascript:PageAction(2,"");'><img src="../../images/save.gif" border="0"></a><font size="1">Click to save this date </font><br>	  </td>
      <td width="65%" align="center">
<%
if(vMonth != null && vMonth.size() > 0) {%>
  		<table width="95%" cellspacing="0" cellpadding="0" title="Default holidays">
	  		<tr bgcolor="#DDDDEE">
				<td width="25%" class="thinborderTOPLEFTBOTTOM">HOLIDAY</td>
				<td width="5%" class="thinborderTOPRIGHTBOTTOM">REMOVE</td>
			    <td width="5%" class="thinborderTOPBOTTOM">&nbsp;</td>
			    <td width="25%" class="thinborderTOPBOTTOM">HOLIDAY</td>
			    <td width="5%" class="thinborderTOPRIGHTBOTTOM">REMOVE</td>
			    <td width="5%" class="thinborderTOPBOTTOM">&nbsp;</td>
			    <td width="25%" class="thinborderTOPBOTTOM">HOLIDAY</td>
			    <td width="5%" class="thinborderTOPRIGHTBOTTOM">REMOVE</td>
	  		</tr>
	  	<%for(int i =0; i < vMonth.size(); i += 9){%>
			<tr bgcolor="#DDDDEE">
	  		  <td class="thinborderLEFTBOTTOM">&nbsp;<%=(String)vMonth.elementAt(i + 1)%> <%=(String)vMonth.elementAt(i + 2)%></td>
	  		  <td class="thinborderRIGHTBOTTOM" align="center">
			  <a href="javascript:PageAction('20','<%=(String)vMonth.elementAt(i)%>');"><img src="../../../images/x_small.gif" border="1"></a></td>
	  		  <td class="thinborderBOTTOM">&nbsp;</td>
	  		  <td class="thinborderBOTTOM">
			  <%if(vMonth.size() > i + 3){%>
				  <%=(String)vMonth.elementAt(i + 1 + 3)%> <%=(String)vMonth.elementAt(i + 2 + 3)%>
			  <%}else{%>&nbsp;<%}%>			  </td>
	  		  <td class="thinborderRIGHTBOTTOM" align="center">
			  <%if(vMonth.size() > i + 3){%>
				  <a href="javascript:PageAction('20','<%=(String)vMonth.elementAt(i + 3)%>');"><img src="../../../images/x_small.gif" border="1"></a>
			  <%}else{%>&nbsp;<%}%>			  </td>
	  		  <td class="thinborderBOTTOM">&nbsp;</td>
	  		  <td class="thinborderBOTTOM">
			  <%if(vMonth.size() > i + 6){%>
				  <%=(String)vMonth.elementAt(i + 1 + 6)%> <%=(String)vMonth.elementAt(i + 2 + 6)%>
			  <%}else{%>&nbsp;<%}%>			  </td>
	  		  <td class="thinborderRIGHTBOTTOM" align="center">
			  <%if(vMonth.size() > i + 6){%>
				  <a href="javascript:PageAction('20','<%=(String)vMonth.elementAt(i + 6)%>');"><img src="../../../images/x_small.gif" border="1"></a>
			  <%}else{%>&nbsp;<%}%>			  </td>
  		  </tr>
		 <%}%>
		</table>	  
<%}else{%>Default holiday list not created<%}%>		</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM"><strong>Individual Date listed holiday for Year : </strong>
        <select name="year_" onChange="ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_"),2,2)%>
        </select>
		&nbsp;&nbsp;
	  <font size="1">Click to view holiday calendar</font>
<%
strTemp = WI.fillTextValue("year_");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(12);
%>	  
	  <a href="./holiday_calendar.jsp?year_=<%=strTemp%>" target="_blank"><img src="../../images/view.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><br>
        Date : <font size="1">
        <input name="date_" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.date_');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"><br>
        </a><a href='javascript:PageAction(3,"");'><img src="../../images/save.gif" border="0"></a><font size="1">Click to save this date </font></font></td>
      <td align="center">
<%
if(vDates != null && vDates.size() > 0) {%>
	  <table width="95%" cellspacing="0" cellpadding="0" title="Default holidays">
          <tr bgcolor="#DDDDEE">
            <td width="25%" class="thinborderTOPLEFTBOTTOM">DATE</td>
            <td width="5%" class="thinborderTOPRIGHTBOTTOM">REMOVE</td>
            <td width="5%" class="thinborderTOPBOTTOM">&nbsp;</td>
            <td width="25%" class="thinborderTOPBOTTOM">DATE</td>
            <td width="5%" class="thinborderTOPRIGHTBOTTOM">REMOVE</td>
            <td width="5%" class="thinborderTOPBOTTOM">&nbsp;</td>
            <td width="25%" class="thinborderTOPBOTTOM">DATE</td>
            <td width="5%" class="thinborderTOPRIGHTBOTTOM">REMOVE</td>
          </tr>
	  	<%for(int i =0; i < vDates.size(); i += 6){%>
          <tr bgcolor="#DDDDEE">
            <td class="thinborderLEFTBOTTOM"><%=(String)vDates.elementAt(i + 1)%></td>
            <td class="thinborderRIGHTBOTTOM" align="center">
			<a href="javascript:PageAction('30','<%=(String)vDates.elementAt(i)%>');"><img src="../../../images/x_small.gif" border="1"></a></td>
            <td class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM">
			  <%if(vDates.size() > i + 2){%>
				  <%=(String)vDates.elementAt(i + 1 + 2)%>
			  <%}else{%>&nbsp;<%}%>			</td>
            <td class="thinborderRIGHTBOTTOM" align="center">
			  <%if(vDates.size() > i + 2){%>
				  <a href="javascript:PageAction('30','<%=(String)vDates.elementAt(i + 2)%>');"><img src="../../../images/x_small.gif" border="1"></a>
			  <%}else{%>&nbsp;<%}%>			</td>
            <td class="thinborderBOTTOM">&nbsp;</td>
            <td class="thinborderBOTTOM">
			  <%if(vDates.size() > i + 4){%>
				  <%=(String)vDates.elementAt(i + 1 + 4)%>
			  <%}else{%>&nbsp;<%}%>			</td>
            <td class="thinborderRIGHTBOTTOM">
			  <%if(vDates.size() > i + 4){%>
				  <a href="javascript:PageAction('30','<%=(String)vDates.elementAt(i + 4)%>');"><img src="../../../images/x_small.gif" border="1"></a>
			  <%}else{%>&nbsp;<%}%>			</td>
          </tr>
		  <%}%>
        </table>
<%}%>		</td>
    </tr>
<%
if(iAccessLevel > 1) {%>
<%}%>	
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>