<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.eDTRUtil,
																eDTR.OverTime" %>
<%
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
</style>
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javscript:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");

	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	int i = 0;	

//add security heot.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record--OVERTIME MANAGEMENT-Overtime Request(Batch)","batch_ot_request_new.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
											request.getRemoteAddr(),"batch_ot_request_new.jsp");	
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT-Request Overtime",request.getRemoteAddr(), 
														"batch_ot_request_new.jsp");	
}
if(bolMyHome && iAccessLevel == 0) { 
	iAccessLevel = 1;	
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
if(bolIsSchool)
	strTemp = "College";
else
	strTemp = "Division";

String[] astrSortByName    = {"Requested By","Date of Request","Date of OT", "No of Hours",
															"Status", "Last Name(Requested for)","Department",strTemp};

String[] astrSortByVal     = {"head_.lname","request_date","ot_specific_date","no_of_hour",
															"approve_stat", "sub_.lname","d_name","c_name"};

int iSearchResult = 0;

String strDateFrom = WI.fillTextValue("DateFrom");
String strDateTo = WI.fillTextValue("DateTo");

if (strDateFrom.length() ==0){
	String[] astrCutOffRange = eDTRUtil.getCurrentCutoffDateRange(dbOP,true);
	if (astrCutOffRange!= null && astrCutOffRange[0] != null){
		strDateFrom = astrCutOffRange[0];
		strDateTo = astrCutOffRange[1];
	}
}

OverTime ot = new OverTime();
Vector vRetResult = null;
boolean bolRetain = true;

String strOTDate = null;
String strOTType = null;
String strHrFr = null;
String strMinFr = null;
String strAMPMFr = null;

String strHrTo = null;
String strMinTo = null;
String strAMPMTo = null;

 	vRetResult = ot.addBatchOTRequestPerRow(dbOP, request, 4);
	if (vRetResult==null){
		strErrMsg =  ot.getErrMsg();
	}else{
		iSearchResult = ot.getSearchCount();
	}

%>
<form name="dtr_op">
   <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
			<% 
				strTemp = " WITH OT REQUEST ON " + WI.fillTextValue("ot_specific_date");
			%>
      <td height="20" colspan="8" align="center" class="thinborder"><strong>LIST OF EMPLOYEES <%=strTemp%></strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder">&nbsp;</td> 
      <td width="25%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="20%" align="center" class="thinborder">&nbsp;</td>
 			<td width="8%" align="center" class="thinborder"><font size="1"><strong>OT Type </strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>No. of Hours</strong></font></td>
			<td width="7%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>			
 			<td width="21%" align="center" class="thinborder"><font size="1"><strong>Details of OT</strong></font><br>
		  </td> 
    </tr>
    
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=28,iCount++){
		 %>
    <tr>
      <td class="thinborder">&nbsp;<%=iCount%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+18), (String)vRetResult.elementAt(i+19),
							(String)vRetResult.elementAt(i+20), 4).toUpperCase()%></strong></font></td>
       <%if((String)vRetResult.elementAt(i + 21)== null || (String)vRetResult.elementAt(i + 22)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>							
      <td nowrap class="thinborder">

			&nbsp;<%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
			                       (String)vRetResult.elementAt(i+8),
										   (String)vRetResult.elementAt(i+9))%> - <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%>			</td>
       <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+24))%></td>
      <%			
				strTemp = (String)vRetResult.elementAt(i+5);
				strTemp = WI.getStrValue(strTemp,"&nbsp;");
			%>
		  <td align="center" class="thinborder"><%=strTemp%></td>
        <%
				strTemp = (String)vRetResult.elementAt(i+13);
				strTemp = WI.getStrValue(strTemp);
				if(strTemp.equals("1")){ 
					strTemp = "APPROVED";
				}else if (strTemp.equals("0")){
					strTemp = "DISAPPROVED";
				}else
					strTemp = "PENDING";
			%>			
			<td align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>			
 			<%
			strTemp = WI.fillTextValue("ot_reason_"+iCount);
			if(bolRetain)
				strTemp = WI.getStrValue(strTemp);
			else
				strTemp = "";
		%>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+23), "&nbsp;")%></td>			
     </tr>
    <%} //end for loop%>
  </table>
	<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td width="15" colspan="4">&nbsp;</td>
		</tr>
	</table>	
<% } // end vRetResult != null && vRetResult.size() > 0 %>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>