<%@ page language="java" import="utility.*, java.util.Vector, osaGuidance.ProgramOfActivity"%>
<%
	WebInterface WI = new WebInterface(request);

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
boolean bolIsCIT = strSchoolCode.startsWith("CIT");

String strThemeObj = null;
if(bolIsCIT)
	strThemeObj = "Theme";
else
	strThemeObj = "Objective";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}
</script>
<%
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./view_poa_list_print.jsp" />
<%}
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrMonthList = {"January","February","March","April","May","June","July","August",
	"September","October","November","December"};
	String strTempIndex = null;
	boolean bolShowRep = true;
	int iCtr = 0;
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-PROGRAM OF ACTIVTIES","view_poa_list.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","PROGRAM OF ACTIVTIES",request.getRemoteAddr(),
														"view_poa_list.jsp");
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

Vector vActivities = null;
Vector vEditInfo = null;

Vector vThemes = new Vector();
Vector vRetResult = new Vector();


ProgramOfActivity POA = new ProgramOfActivity();
if(WI.fillTextValue("sy_from").length() > 0) 
	//vActivities = POA.viewPOAList(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("viewType"));
	vActivities =  POA.viewPOAList(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("viewType"),
	 WI.fillTextValue("date_range_from"), WI.fillTextValue("date_range_to"));
	 
if(vActivities !=null){	 
	if(WI.fillTextValue("viewType").equals("2")){
		vThemes = (Vector) vActivities.remove(0);
		vRetResult = (Vector)vActivities.remove(0);
	}
}
%>
<body bgcolor="#D2AE72">
<form action="./view_poa_list.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          PROGRAM OF ACTIVITIES PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="5%" height="25">&nbsp;</td>
      <td width="95%"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="15%" >School year</td>
      <td width="28%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
      </td>
      <td width="52%">
	  <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr>
    	<td height="25">&nbsp;</td>
    	<td>Arrange by: </td>
    	<td colspan="2" valign="middle"><font size="1">
    	<%
		strTemp = WI.fillTextValue("viewType");
    	
    	if (strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";		
		%><input type="radio" value="0" name="viewType" <%=strErrMsg%>><%=strThemeObj%>s
		
		<%
		if (strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";		
		%><input type="radio" value="1" name="viewType" <%=strErrMsg%>>Activities
		
		<%
		if (strTemp.equals("2"))
			strErrMsg = "checked";
		else
			strErrMsg = "";		
		%><input type="radio" value="2" name="viewType" <%=strErrMsg%>>All
    	
    	</font>
    	</td>
    </tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Date Range</td>
		<td colspan="2">
		<% strTemp = WI.fillTextValue("date_range_from");%>
		<input name="date_range_from" type="text" value="<%=strTemp%>" size="10" readonly="true" class="textbox"  
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
		<a href="javascript:show_calendar('form_.date_range_from');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0"></a> To
		<% strTemp = WI.fillTextValue("date_range_to");%>
		<input name="date_range_to" type="text" value="<%=strTemp%>" size="10" readonly="true" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('form_.date_range_to');" title="Click to select date"
		onMouseOver="window.status='Select date'; return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0">
		</a>
		</td>
	</tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0){
if (WI.fillTextValue("viewType").equals("0") || WI.fillTextValue("viewType").equals("2")){
    if(WI.fillTextValue("viewType").equals("2")){
	   vActivities = (Vector) vThemes; 
	}

	if (vActivities != null && vActivities.size()>0) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  	<tr bgcolor="#B9B292">
  		<td colspan="4" height="20" align="center" class="thinborder"><font color="#FFFFFF"><strong>PROGRAM OF ACTIVITIES</strong></font></td>
  	</tr>
  	<tr>
  		<td width="7.5%" height="20" align="center" class="thinborder"><strong>ORDER</strong></td>
  		<td width="27.5%" align="left" class="thinborder"><strong>&nbsp;<%=strThemeObj.toUpperCase()%></strong></td>
  		<td width="22.5%" align="left" class="thinborder"><strong>&nbsp;DATE</strong></font></td>
  		<td width="42.5%" align="left" class="thinborder"><strong>&nbsp;ACTIVITY</strong></td>
  	</tr>
	<%for (iCtr=0;iCtr<vActivities.size();iCtr+=7){%>
  	<tr>
		<%//if (iCtr >0 && vActivities.elementAt(iCtr+2).equals(vActivities.elementAt(iCtr-5)))
			//bolShowRep = false;
		//else
			//bolShowRep = true;%>
  		<td class="thinborder" height="25" align="center">&nbsp;
		<%//if (bolShowRep){%><%=(String)vActivities.elementAt(iCtr+1)%><%//}%></td>
  		<td class="thinborder">&nbsp;<%//if (bolShowRep){%><%=(String)vActivities.elementAt(iCtr+3)%><%//}%></td>
      <!--
	  	<td class="thinborder">&nbsp;<%//=astrMonthList[Integer.parseInt((String)vActivities.elementAt(iCtr + 4))]%>,
		  <%//=(String)vActivities.elementAt(iCtr + 5)%></td>
		  -->
		  <td class="thinborder">&nbsp;<%=(String) vActivities.elementAt(iCtr+4)%> 
		  <%=WI.getStrValue((String) vActivities.elementAt(iCtr+5), " - ","","")%>
  		<td class="thinborder">&nbsp;<%=(String)vActivities.elementAt(iCtr+6)%></td>
  	</tr>
  	<%}%>
  </table>
<%}} if(WI.fillTextValue("viewType").equals("1") || WI.fillTextValue("viewType").equals("2")) {
   if(WI.fillTextValue("viewType").equals("2")){
       vActivities = null;
	   vActivities = (Vector)vRetResult;   
   }
 
 if (vActivities!= null && vActivities.size()>0){%>	 <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  	<tr bgcolor="#B9B292">
  		<td colspan="4" height="20" align="center"class="thinborder"><font color="#FFFFFF" ><strong>PROGRAM OF ACTIVITIES</strong></font></td>
  	</tr>
  	<tr>
  		<td width="20%%" height="20" align="center" class="thinborder"><strong>DATE</strong></td>
  		<td width="32.5%%" align="left" class="thinborder"><strong>&nbsp;ACTIVITY</strong></td>
  		<td width="25%" align="left" class="thinborder"><strong>&nbsp;VENUE</strong></font></td>
  		<td width="22.5%" align="left" class="thinborder"><strong>&nbsp;<%=strThemeObj.toUpperCase()%></strong></td>

  	</tr>
	<%for (iCtr=0;iCtr<vActivities.size();iCtr+=6){%>
  	<tr>
  		<!--<td class="thinborder" height="25" align="center">&nbsp;
  		<%//=astrMonthList[Integer.parseInt((String)vActivities.elementAt(iCtr + 1))]%>,
		  <%//=(String)vActivities.elementAt(iCtr + 2)%>
  		</td>-->
		<td class="thinborder" height="25" align="center">&nbsp;
		<%=(String) vActivities.elementAt(iCtr+1)%> <%=WI.getStrValue((String) vActivities.elementAt(iCtr +2),"- ","","")%>		
		</td>
  		<td class="thinborder">&nbsp;<%=(String)vActivities.elementAt(iCtr+3)%></td>
  		<td class="thinborder">&nbsp;<%=(String)vActivities.elementAt(iCtr + 4)%></td>
  		<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vActivities.elementAt(iCtr+5),"No Objectives")%>
  		<%for (;iCtr<vActivities.size(); iCtr+=6){
  			strTempIndex = (String)vActivities.elementAt(iCtr);
  			if((iCtr+6)<vActivities.size() && strTempIndex.equals((String)vActivities.elementAt(iCtr+6))){%>
			<br>&nbsp;<%=(String)vActivities.elementAt(iCtr+11)%><%} else break;}%>  		
  		</td>
  	</tr>
  	<%}%>
  </table>
<%}}}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="tFooter">
    <tr>
      <td height="30" colspan="9" align="center"><%if (vActivities!= null && vActivities.size()>0){%>
      <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a><%} else {%>&nbsp;<%}%></td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
   	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>