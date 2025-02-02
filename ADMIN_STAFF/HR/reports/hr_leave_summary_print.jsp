<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,
								hr.HRInfoLeave"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Summary per Department/College</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size: 11px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	boolean bolMyHome = false;
	


//add security hehol.

	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Application","leave_summary.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"leave_summary.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){//for my home, allow applying leave.
		//if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		//else 
		//	iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//

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

String strSchName  = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddr1    = SchoolInformation.getAddressLine1(dbOP,false,false);
String strAddr2    = SchoolInformation.getAddressLine2(dbOP,false,false);
String strTitle    = WI.fillTextValue("bonus_name") + " for the Year " + WI.fillTextValue("year_of");
String strDateTime = WI.getTodaysDateTime();

Vector vRetResult = null;
HRInfoLeave hrPx = new HRInfoLeave();

int iAction =  -1;
 String strSYFrom = WI.fillTextValue("sy_from");
 String strSYTo = WI.fillTextValue("sy_to");
 String strSemester = WI.fillTextValue("semester");
 String strCurrUserIndex = "";
 String strOffice = "";
 String strCurOffice = "";
 boolean bolPageBreak = false;
 vRetResult = hrPx.getLeaveSummary(dbOP, request);
 if (vRetResult != null) {			
	 int iCount = 0;
	 int i = 0;
	 int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	 int iNumRec = 0;//System.out.println(vRetResult);
	 int iIncr    = 1;
	 int iTotalPages = (vRetResult.size())/(11*iMaxRecPerPage);	
   if((vRetResult.size() % (11*iMaxRecPerPage)) > 0) ++iTotalPages;
	 int iPage = 1; 
	 
	 for (;iNumRec < vRetResult.size();iPage++){
		strCurrUserIndex = "";
		strOffice = "";
%>
<body onLoad="javascript:window.print();">
<form name="form_">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td align="center"><font size="2"><strong><%=strSchName%></strong></font><br>
		   <font size="1">
				<%=strAddr1%><br><%=strAddr2%>
				<div align="right">
					Date and Time Printed: <%=strDateTime%> &nbsp;&nbsp; &nbsp; &nbsp; Page <%=iPage%> of <%=iTotalPages%>
				</div>
		   </font></td>
	  </tr>
	</table>
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
			<tr> 
				<td height="21" colspan="5" align="center" class="thinborder"><strong>SUMMARY OF LEAVE </strong></td>
			</tr>
			<tr style="font-weight:bold">
				<td width="32%" class="thinborder">&nbsp;</td> 
				<td width="30%" height="25" class="thinborder"> &nbsp;Type of Leave</td>
				<td width="10%" align="center" class="thinborder">Leave Credit </td>
				<td width="10%" align="center" class="thinborder">Consumed</td>
				<td width="10%" align="center" class="thinborder">Available</td>
			</tr>
	<%
		double dLeaveCredit = 0d;
	for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=11,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;			
	strCurOffice = WI.getStrValue((String)vRetResult.elementAt(i+8),(String)vRetResult.elementAt(i+10));
	strCurOffice = WI.getStrValue(strCurOffice, "n/a");
	if (!strOffice.equals(strCurOffice)){ 
		strOffice = strCurOffice;
	strOffice = WI.getStrValue(strOffice);
	%>
			<tr> 
			 <td height="25" colspan="5" class="thinborder">
		&nbsp;<strong>OFFICE : <%=strOffice.toUpperCase()%></strong></td>
			</tr>		  
	<%}%>
			<tr>
				<%
				if (!strCurrUserIndex.equals((String)vRetResult.elementAt(i))){
					strCurrUserIndex = (String)vRetResult.elementAt(i);
					strTemp = (String)vRetResult.elementAt(i+6);
				}else{
					strTemp = "";
				}
				%>
				<td class="thinborder">&nbsp;<%=strTemp%></td> 
				
			 <td height="22" class="thinborder">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
				 <%
				 	dLeaveCredit = Double.parseDouble((String)vRetResult.elementAt(i+3)) + Double.parseDouble((String)vRetResult.elementAt(i+4));
					
					if(strSchCode.startsWith("DEPED"))
						strTemp = CommonUtil.formatFloat(dLeaveCredit, 3);
					else
						strTemp = CommonUtil.formatFloat(dLeaveCredit, false);
				 %>
				 <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
				 <%
				 	strTemp = (String)vRetResult.elementAt(i+4);
					if(strSchCode.startsWith("DEPED"))
						strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp), 3);
					else
						strTemp = CommonUtil.formatFloat(strTemp, false);
				 %>			 
			 <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
				 <%
				 	strTemp = (String)vRetResult.elementAt(i+3);
					if(strSchCode.startsWith("DEPED"))
						strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp), 3);
					else
						strTemp = CommonUtil.formatFloat(strTemp, false);
				 %>			 
			 <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		  </tr>
			<%} // end for loop %>
		</table>
 
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>	
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
