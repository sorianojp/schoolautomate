<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.eDTRUtil" %>
<%
WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View OverTime Requests</title>
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
<style  type="text/css">
TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
TD.thinborder{
	font-size:10px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
</style>
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
	function ViewRecords(){
		document.dtr_op.print_page.value = "";
		document.dtr_op.viewAll.value=1;
	}
	function goToNextSearchPage()	{
		document.dtr_op.viewAll.value=1;
		document.dtr_op.submit();
	}
	function ViewDetails(index){
	
	var loadPg = "./validate_approve_ot.jsp?info_index="+index+"&iAction=3";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=447,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
	
	}
	function printpage(){
		document.dtr_op.print_page.value = "1";
		document.dtr_op.submit();
	}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.req_for_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.dtr_op.req_for_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}	
	
-->
</script>
<body onLoad="javascript:window.print();">
<%
  DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	

	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	boolean bolHasInternal = false;
	int i = 0;	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-OVERTIME MANAGEMENT-View/Edit Overtime","deleted_ot_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");
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
int iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","OVERTIME MANAGEMENT",
											request.getRemoteAddr(),"deleted_ot_print.jsp");	
if(iAccessLevel == 0){
 iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","OVERTIME MANAGEMENT-View/Edit Overtime",
											request.getRemoteAddr(),"deleted_ot_print.jsp");	
}
if(iAccessLevel == 0){
 iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","STATISTICS & REPORTS",
											request.getRemoteAddr(),"deleted_ot_print.jsp");	
}

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
int iSearchResult = 0;

ReportEDTR RE = new ReportEDTR(request);
eDTR.OverTime ot = new eDTR.OverTime();

Vector vRetResult = null;

boolean bolAllowOTCost = false;
int iTempMin = 0;
int iTempHr = 0;
double dTemp = 0d;
double dHoursOT = 0d;

String strSQLQuery = 
					"select restrict_index from edtr_restrictions where restriction_type = 1 " +
					" and user_index_ = " + (String)request.getSession(false).getAttribute("userIndex");
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null)
	bolAllowOTCost = true;


	vRetResult = RE.searchOvertime(dbOP, true);
%>
<form action="./deleted_ot_print.jsp" method="post" name="dtr_op">
<% if (vRetResult != null){ %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="10%" height="25" colspan="6" align="center"><font color="#000000"><strong>LIST 
      OF DELETED OVERTIME SCHEDULE REQUEST</strong></font></td>
  </tr>
  <tr>
    <td colspan="6"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <%if(WI.fillTextValue("show_division").length() > 0){%>
				<td width="18%" align="center" class="thinborder"><strong><font size="1">Department / Office</font></strong></td>
				<%}%>
        <td width="19%" align="center" class="thinborder"><strong><font size="1">Requested 
          by </font></strong></td>
        <td width="19%" align="center" class="thinborder"><font size="1"><strong>Requested 
          For</strong></font></td>
        <td width="10%" align="center" class="thinborder"><font size="1"><strong>Date 
          of Request</strong></font></td>
        <td width="10%" align="center" class="thinborder"><font size="1"><strong>OT 
          Date</strong></font></td>
        <td width="12%" align="center" class="thinborder"><font size="1"><strong>Inclusive 
          Time</strong></font></td>
        <td width="4%" align="center" class="thinborder"><font size="1"><strong>No. 
          of Hours</strong></font></td>
        <%if(WI.fillTextValue("show_details").length() > 0){%>
				<td width="11%" align="center" class="thinborder"><font size="1"><strong>Details</strong></font></td>
        <%}%>
				
				<%if(WI.fillTextValue("show_cost").length() > 0){%>
				<td width="6%" align="center" class="thinborder"><font size="1"><strong>Cost</strong></font></td>
				<%}%>
				<%if(WI.fillTextValue("show_delete").length() > 0){%>
				<td width="11%" align="center" class="thinborder"><strong><font size="1">DELETE DETAIL </font></strong></td>
				<%}%>
      </tr>
        <%
			int iCtr = 0;
			for (i=0 ; i < vRetResult.size(); i+=45){ 
		 %>
      <tr>
				<%if(WI.fillTextValue("show_division").length() > 0){%>
				<%if((String)vRetResult.elementAt(i + 21)== null || (String)vRetResult.elementAt(i + 23)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}
				%>				
        <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 21),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 23),"")%> </td>
				<%}%>
				<%
				strTemp2 = WI.formatName((String)vRetResult.elementAt(i+15), 
									(String)vRetResult.elementAt(i+16), (String)vRetResult.elementAt(i+17), 4);
				strTemp = (String)vRetResult.elementAt(i);				
				%>
        <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp2, "", "<br>(" + strTemp + ")","")%></td>
        <% if (strTemp.equals((String)vRetResult.elementAt(i+1)))
						strTemp = "&nbsp;";
					else{
						strTemp = WI.formatName((String)vRetResult.elementAt(i+18), 
											(String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), 4);
						strTemp += "<br>(" + (String)vRetResult.elementAt(i+1) + ")";
					}
				%>
        <td class="thinborder">&nbsp;<%=strTemp%></td>
        <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
        <% 
		   		strTemp = eDTRUtil.formatWeekDay((String)vRetResult.elementAt(i+6));
		   		if (strTemp  == null || strTemp.length() < 1){
		   			strTemp = (String)vRetResult.elementAt(i+4);
			    }else{
					strTemp = " every " + strTemp + "<br>(" + (String)vRetResult.elementAt(i+4) + 
							" - " +	(String)vRetResult.elementAt(i+5) + ")";
				}
			%>
        <td align="center" class="thinborder">          <%=strTemp%></td>
        <td align="center" class="thinborder">
					<%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
			                               (String)vRetResult.elementAt(i+8),
										   (String)vRetResult.elementAt(i+9))%> - <br>
                  <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%></td>
				<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), false);
				if(WI.fillTextValue("show_actual").length() > 0){
					strTemp = ConversionTable.replaceString(strTemp, ",","");
					dHoursOT = Double.parseDouble(strTemp);
					iTempHr = (int)dHoursOT;
					dTemp = dHoursOT - iTempHr;
					iTempMin = (int)((dTemp * 60) + 0.2);
					strTemp = iTempHr + ":" + CommonUtil.formatMinute(Integer.toString(iTempMin));
				}				
				%>
        <td class="thinborder">&nbsp;<%=strTemp%></td>
				<%if(WI.fillTextValue("show_details").length() > 0){%>
				<%
					strTemp = (String)vRetResult.elementAt(i+29);	
					strTemp = WI.getStrValue(strTemp,"&nbsp;");
					strTemp += WI.getStrValue((String)vRetResult.elementAt(i+35), "<br>-<font color='#FF0000'>", "</font>","");
				%>
        <td class="thinborder"><%=strTemp%></td>
				<%}%>         
        <%if(WI.fillTextValue("show_cost").length() > 0){%>
				<td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+28)%></td>
				<%}%>	
				<%if(WI.fillTextValue("show_delete").length() > 0){%>
				<%
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+37),"","<br>","");
					strTemp += WI.getStrValue((String)vRetResult.elementAt(i+38));
				%>
				<td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
				<%}%>
      </tr>
      <%}%>
    </table></td>
  </tr>
</table>

<% }%>
  <input type="hidden" name="viewAll" value="">
<input type="hidden" name="search_deleted" value="1">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>