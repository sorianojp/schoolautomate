<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";

boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
@media print { 
  @page {
		size:8.50in 3.50in; 
		margin-bottom:0in;
		margin-left:.1in;
		margin-right:.1in;
		margin-top:0in;
	}
}
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
</style>
<body>
<%
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Completion","grade_completion_slip_print.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Completion",request.getRemoteAddr(),
									null);

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
GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

Vector vStudInfo =  null;
Vector vGradeDetail = null;
Vector vSelectedGSIndex = new Vector();

Vector vRemarks = new Vector();
vRemarks.addElement("inr");
vRemarks.addElement("ine");
vRemarks.addElement("inc");
vRemarks.addElement("incomplete");
vRemarks.addElement("inp");

String strRemark  = null;
String strUserIndex   = null;
String strSelectedGSIndex = WI.fillTextValue("strSelectedGSIndex");

if(strSelectedGSIndex.length() == 0)
	strErrMsg = "Grade information not found.";
else{
	vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));		
	if(vStudInfo == null)
		strErrMsg = pmtUtil.getErrMsg();
	else
	{
		vSelectedGSIndex = CommonUtil.convertCSVToVector(strSelectedGSIndex);
		vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),request.getParameter("sy_from"),
			request.getParameter("sy_to"),request.getParameter("semester"),true,true,true);//get all information.
		strUserIndex = (String)vStudInfo.elementAt(0);
		if(vGradeDetail == null)
			strErrMsg = GS.getErrMsg();
		else{		
			
			boolean bolContainsINE = false;
			java.sql.ResultSet rs = null;
			
			strTemp = 	
				" select s_index, fname, mname, lname  "+
				" from G_SHEET_FINAL  "+
				" join FACULTY_LOAD on (FACULTY_LOAD.SUB_SEC_INDEX = G_SHEET_FINAL.SUB_SEC_INDEX) "+
				" join USER_TABLE on (USER_TABLE.USER_INDEX = FACULTY_LOAD.USER_INDEX) "+
				" where FACULTY_LOAD.IS_VALID = 1 "+
				" and IS_MAIN = 1 "+
				" and GS_INDEX = ? ";
				
			java.sql.PreparedStatement pstmtSelect = dbOP.getPreparedStatement(strTemp);
			
			for(int i=0; i< vGradeDetail.size(); i += 8){
				strRemark  = WI.getStrValue(vGradeDetail.elementAt(i+6),"&nbsp;");											
				//if(strRemark.toLowerCase().indexOf("inc") == -1 && strRemark.toLowerCase().indexOf("inr") == -1 && strRemark.toLowerCase().indexOf("ine") == -1)
				if(vRemarks.indexOf(strRemark.toLowerCase()) == -1)
					continue;
				bolContainsINE = true;
				
				/*if(vGradeDetail.elementAt(i) == null)
					continue;*/
				
				pstmtSelect.setString(1, (String)vGradeDetail.elementAt(i));
				rs = pstmtSelect.executeQuery();
				if(rs.next()){
					strTemp = GS.getLoadingForSubject(dbOP, rs.getString(1));
					vGradeDetail.setElementAt(strTemp, i + 3);
					strTemp = WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4);
					vGradeDetail.setElementAt(strTemp, i + 4);
				}rs.close();		
			}		
			
			if(!bolContainsINE){
				vGradeDetail = new Vector();
				strErrMsg = "Grades for completion data not found.";
			}
			
		}
	}
}



if(strErrMsg != null){
	dbOP.cleanUP();
%>
<div align="center"><%=WI.getStrValue(strErrMsg)%></div>
<%return;}%>
<%
if(vGradeDetail != null && vGradeDetail.size() > 0){

int iMaxLineCount = 7;
int iLineCount = 0;
boolean bolPageBreak = false;
String strGrade   = null;
String strCEarned = null;
int iIndexOf = 0;
for(int i=0; i< vGradeDetail.size(); ){
iLineCount = 0;
if(bolPageBreak){
	bolPageBreak = false;%>
	<div style="page-break-after:always;">&nbsp;</div>
<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="6" align="center" style="font-size:13px;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
	APPLICATION FOR COMPLETION EXAMINATION</td></tr>
	<tr><td colspan="6" align="right" style="padding-right:60px; font-size:9px;">
		<%=(String)request.getSession(false).getAttribute("first_name")+" &nbsp; "+WI.getTodaysDateTime()%></td></tr>
	<tr>
		<td width="12%" height="20" class="thinborderTOPBOTTOM">STUDENT NO:</td>
		<td width="14%" class="thinborderTOPBOTTOM"><%=WI.fillTextValue("stud_id")%></td>
		<td width="8%" class="thinborderTOPBOTTOM">NAME:</td>
		<td width="41%" class="thinborderTOPBOTTOM"><%=(String)vStudInfo.elementAt(1)%></td>
		<td width="10%" class="thinborderTOPBOTTOM">COURSE/YR:</td>
		<td width="15%" class="thinborderTOPBOTTOM">
		<%=(String)vStudInfo.elementAt(2)%>
        <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%>&nbsp; &nbsp;<%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%>
		</td>
	</tr>
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td valign="top" height="150">
			<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="14%" height="18">&nbsp;</td>
					<td width="40%">DESCRIPTION</td>
					<td width="7%" align="center">UNIT</td>
					<td width="8%">INR/INE</td>
					<td width="9%">SEMESTER</td>
					<td width="22%" align="center">INSTRUCTOR</td>
				</tr>
				<%				
				for(; i< vGradeDetail.size(); i+=8){
				
				strRemark  = WI.getStrValue(vGradeDetail.elementAt(i+6),"&nbsp;");				
				//if(strRemark.toLowerCase().indexOf("inc") == -1 && strRemark.toLowerCase().indexOf("inr") == -1 && strRemark.toLowerCase().indexOf("ine") == -1)
				if(vRemarks.indexOf(strRemark.toLowerCase()) == -1)
					continue;
					
				//get only the data that is selected in the main
				iIndexOf = vSelectedGSIndex.indexOf((String)vGradeDetail.elementAt(i));	
				if(iIndexOf == -1)
					continue;
					
				strGrade   = (String)vGradeDetail.elementAt(i+5);
				strCEarned = WI.getStrValue(vGradeDetail.elementAt(i+3),"&nbsp;");				
				%>
					<tr>
					  <td  height="18">&nbsp;<%=(String)vGradeDetail.elementAt(i + 1)%></td>
					  <td>&nbsp;<%=((String)vGradeDetail.elementAt(i+2)).toUpperCase()%></td>
					  <td align="center"><%=strCEarned%></td>
					  <td>&nbsp;<%=strGrade%></td>
					  <%
					  strTemp = WI.fillTextValue("semester")+WI.fillTextValue("sy_from");
					  if(Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"),"0")) == 0)
					  	strTemp = WI.fillTextValue("semester")+WI.fillTextValue("sy_to");
					  %>
					  <td><%=strTemp%></td>
					  <td><%=WI.getStrValue((String)vGradeDetail.elementAt(i+4),"n/f")%></td>					  
					</tr>
				<%
				
				if(++iLineCount > iMaxLineCount){
					i+=8;
					bolPageBreak = true;
					break;
				}
				}%>				
			</table>
		</td>
	</tr>	
<tr><td class="thinborderTOP" align="center">PLEASE FOLLOW STEPS STRICTLY</td></tr>	
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="25%" height="18">Step 1: College Dean</td>
		<td width="25%">Step 2: SAS</td>
		<td width="25%">Step 3: Teller</td>
		<td width="25%">Step 4: EDP</td>
	</tr>
	<tr>
		<td height="18">&nbsp;</td>
		<td height="18">&nbsp;</td>
		<td height="18">Amount:</td>
		<td height="18">&nbsp;</td>
	</tr>
	<tr>
		<td height="18">College Dean</td>
		<td height="18">Balance Verification</td>
		<td height="18">Teller Signature:</td>
		<td height="18">Clerk, EDP Center</td>
	</tr>
</table>
<%}//end outer loop%>
<script>
	window.print();
</script>

<%
}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
