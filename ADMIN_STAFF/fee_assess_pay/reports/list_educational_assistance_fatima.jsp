<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrConvertSem= {"Summer","1st Term","2nd Term","3rd Term","4th Term"};

	WebInterface WI = new WebInterface(request);

//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments Print","list_educational_assistance_fatima.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
							//							"fee_adjustment.jsp");
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
Vector vRetResult = null;
ReportFeeAssessment rFA = new ReportFeeAssessment();
	vRetResult = rFA.getStudListAssistance(dbOP,request);
	if(vRetResult == null) {
		strErrMsg = rFA.getErrMsg();
	}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
boolean bolShowUnitEnrolled = false; int iIndexOf = 0;
Vector vUnitEnrolled = new Vector();//only if vma.
if(WI.fillTextValue("unit_enrolled").length() > 0) {
	bolShowUnitEnrolled = true;
	CommonUtil.setSubjectInEFCLTable(dbOP);
	String strSQLQuery = "select user_index, sum(unit_enrolled) from ENRL_FINAL_CUR_LIST "+
						"join subject on (subject.sub_index = EFCL_SUB_INDEX) "+
						"join subject_group on (subject.group_index = subject_group.group_index) "+
						"where is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+" and current_semester = "+WI.fillTextValue("semester")+
						" and IS_TEMP_STUD = 0 and exists (select * from FA_STUD_PMT_ADJUSTMENT where sy_from = ENRL_FINAL_CUR_LIST.sy_from and semester = CURRENT_SEMESTER "+
						"and is_valid = 1 and user_index = ENRL_FINAL_CUR_LIST.user_index) and group_name <> 'NSTP' and UNIT_ENROLLED > 0 group by user_index";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vUnitEnrolled.addElement(new Integer(rs.getInt(1)));
		vUnitEnrolled.addElement(rs.getString(2));
	}
	rs.close();
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Scholarship Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css"  type="text/css" rel="stylesheet">
<link href="../../../css/tableBorder.css"  type="text/css" rel="stylesheet">
<style type="text/css">
<!--
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


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }

    TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
</head>
<body onLoad="window.print();">
<%if(strErrMsg != null) {%>
	<p align="center" style="font-weight:bold; font-size:14px; color:#FF0000"><%=strErrMsg%></p>
<%}
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25"><div align="center"><font size="2"><strong>LIST OF STUDENTS WITH EDUCATIONAL ASSISTANCE</strong></font><br>
          SY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>, <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <tr> 
      <td width="14%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>COURSE<%if(!bolIsBasic){%>- YEAR<%}%></strong></font> </div></td>
<%if(bolShowUnitEnrolled) {%>
	  <td width="8%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">UNIT ENROLLED </td>
<%}%>
	  <td width="35%" class="thinborder"> <div align="center"><font size="1"><strong>GRANT NAME</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
    </tr>
<% 
/**
 *  [0] = total Student.   [1] = total Disc Amt.
 *  [0] student index [1] Stud Name [2] fa_fa_indexs  [3] main adjustment 
 *  [4] sub adjustment type 1  [5] sub adjustment type 2  [6] sub adjustment type 3
 *  [7] discount   [8] discount unit   [9] discount on  [10] year level 
 *  [11] id number  [12]  course  [13]  major  [14]  amount
 *   
 */
for(int i = 2; i < vRetResult.size(); i += 17){
	strTemp = (String)vRetResult.elementAt(i+10);
	if(bolIsBasic)	
		strTemp = dbOP.getBasicEducationLevel(Integer.parseInt(strTemp));
	else {
		if(vRetResult.elementAt(i+8) != null)
			strTemp = strTemp + " - "+vRetResult.elementAt(i+8);
	}	
		
%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
<%if(bolShowUnitEnrolled) {
iIndexOf = vUnitEnrolled.indexOf(new Integer((String)vRetResult.elementAt(i)));
if(iIndexOf == -1)
	strTemp = "&nbsp;";
else 
	strTemp = (String)vUnitEnrolled.elementAt(iIndexOf + 1);	
	%>
	  <td class="thinborder"><%=strTemp%></td>
<%}%>
	  <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"/","","")%></font></td>
      <td class="thinborder" align="right"><font size="1"><%=(String)vRetResult.elementAt(i+12)%></font></td>
    </tr>
<%}%>
  </table>
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>