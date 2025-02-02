<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Recompute EDTR Undertime</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function UpdateRecords()
{
	document.form_.update_records.value="1";
	this.SubmitOnce('form_');
}

function ReloadPage(){
	document.form_.update_records.value="";
	document.form_.print_pg.value="";
	this.SubmitOnce('form_');
}

function PrintPg (){
	document.form_.print_pg.value="1";
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){%>
    <jsp:forward page="./update_ut_print.jsp"/>
<% 
return;}
	
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","update_ut_special.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"dtr_update_old.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
if(strErrMsg == null) strErrMsg = "";


ReportEDTR RE = new ReportEDTR(request);
int iResult = 0;
String[] astrAMPM = {"AM","PM"};
Vector vRetResult = null;
int iSearchResult = 0;

if (WI.fillTextValue("update_records").equals("1")) { 
	iResult = RE.updateUndertimeForDay(dbOP);
	if(iResult < 0)
		strErrMsg = RE.getErrMsg();
	else
		strErrMsg = "Updated " + iResult + " records";
}
vRetResult = RE.getUndertimeUpdates(dbOP);
if(vRetResult != null && vRetResult.size() > 0)	
	iSearchResult = RE.getSearchCount();
%>

<form name="form_" action="./update_ut_special.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        DTR OPERATIONS - UPDATE  UNDERTIME RECORDS ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" ><strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    

    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="21%" height="25">Date</td>
      <td width="76%" height="25"><input name="date_update" type="text" size="10" maxlength="10" 
	  value="<%=WI.fillTextValue("date_update")%>" onFocus="style.backgroundColor='#D3EBFF'" 
		class="textbox" onKeyUp="AllowOnlyIntegerExtn('form_','date_update','/');"	  
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_update','/')">
        <a href="javascript:show_calendar('form_.date_update');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Minutes to adjust </td>
      <td height="25"><input name="min_remove" type="text" size="10" maxlength="10" 
	  value="<%=WI.fillTextValue("min_remove")%>" class="textbox" 
	  onKeyUp="AllowOnlyInteger('form_','date_from');" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','min_remove')"></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18"><select name="am_pm">
        <option value="0" >A.M. (First login set)</option>
        <%	if (WI.fillTextValue("am_pm").compareTo("1") == 0){ %>
        <option value="1" selected>P.M. (Second login set)</option>
        <%}else{%>
        <option value="1">P.M. (Second login set)</option>
        <%}%>
      </select>
			<%
				strTemp = WI.fillTextValue("remove_awol");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
			<input type="checkbox" name="remove_awol" value="1" <%=strTemp%>>
			Remove also  AWOL record for login schedule</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Reason for adjustment </td>
      <td height="25"><input name="reason" type="text" size="64" maxlength="256" 
	  value="<%=WI.fillTextValue("reason")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong>Warning! Once the adjustment transaction is saved, all the records that were updated cannot be undone.</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
			<%if(iAccessLevel == 2){%>
			<font size="1">
        <input type="button" name="12" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:UpdateRecords();">
        click to save  new adjustment 
        <input type="button" name="122" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
      click to clear entries </font>
			<%}else{%>
				Not Authorized
			<%}%>
			</td>
    </tr>
 </table>
 <%if(vRetResult != null && vRetResult.size() > 0){%>
 <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="right"><font size="2">Number of  rows Per 
          Page :</font><font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( int i = 15; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
      <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font><a href="javascript:PrintPg();"></a></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/RE.defSearchSize;		
	if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr>
      <td height="25" align="right"><font size="2">Jump To page:
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
      </font></td>
    </tr> 
		<%}%>
  </table>
 <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="4" align="center" class="thinborder"><strong>LIST OF UPDATES MADE </strong></td>
    </tr>
    <tr> 
      <td width="15%" height="25" align="center" class="thinborder"><strong>&nbsp;DATE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>Minutes adjusted </strong></td>
      <td width="51%" align="center" class="thinborder"><strong>Reason for adjustment </strong></td>
      <td width="24%" align="center" class="thinborder"><strong>&nbsp;Updated by </strong></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+=9) { %>
    <tr> 
      <td class="thinborder" height="22">&nbsp;<%=(String)vRetResult.elementAt(i+1)%> - <%=astrAMPM[Integer.parseInt((String)vRetResult.elementAt(i+2))]%></td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+6), 
		 			  		 (String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8), 1)%></td>
    </tr>
    <%} // end for loop%>
  </table>
	<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
    <tr>
      <td height="25"><strong>Page info:</strong> This is a utility for updating/ removing specified number of minutes undertime to ALL employee dtr for the date entered. </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>  
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25">&nbsp;</td>
    </tr>  
</table>

<input type="hidden" name="update_records" value="0">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>