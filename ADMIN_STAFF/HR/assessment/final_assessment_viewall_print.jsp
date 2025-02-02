<%@ page language="java" import="utility.*,hr.HREvaluationSheet,java.util.Vector" %>
<%

boolean bolIsSchool = false;
if ((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>

<body>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;

	
	Vector vRetResult = null;
	Vector vEvalPeriod = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Assessment and Evaluation","final_assessment_viewall.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"final_assessment_viewall.jsp");
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




HREvaluationSheet hrES = new HREvaluationSheet(request);

if(WI.fillTextValue("sy_from").length() > 0) {
	vEvalPeriod = hrES.operateOnEvalPeriod(dbOP, request, 4);
}
if(vEvalPeriod != null){
	vRetResult = hrES.operateOnFinalEval(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = hrES.getErrMsg();	
}


if(vRetResult != null && vRetResult.size() > 0){
int iIndexOf = 0;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td align="center">
			<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
			<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
			<%=SchoolInformation.getAddressLine2(dbOP,false,false)%><br><br>
			<strong>EVALUATION AND ASSESSMENT SUMMARY</strong><br>
			<%
			strErrMsg = "";
			if(WI.fillTextValue("criteria_index").length() >0){
				strTemp = "select criteria_name from HR_EVAL_CRITERIA where CRITERIA_INDEX = "+WI.fillTextValue("criteria_index");
				strErrMsg  = dbOP.getResultOfAQuery(strTemp, 0);
			}
			strTemp = "";
			iIndexOf = vEvalPeriod.indexOf(WI.fillTextValue("eval_period_index"));
			if(iIndexOf > -1)
				strTemp = (String)vEvalPeriod.elementAt(iIndexOf + 1) + " to " + (String)vEvalPeriod.elementAt(iIndexOf + 2);
			%><%=WI.getStrValue(strErrMsg,"EVALUATION for ","","").toUpperCase()%><br><%=WI.getStrValue(strTemp,"From ","","")%>
		</td>
	</tr>
	<tr><td height="20">&nbsp;</td></tr>
</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="13%" height="25"  class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE 
          ID</font></strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong><font size="1">NAME (LNAME,FNAME 
          MI)</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYMENT STATUS</font></strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong><font size="1">POSITION</font></strong></div></td>
      <td width="30%" class="thinborder"><div align="center"><strong><font size="1">
	  <% if (bolIsSchool){%>COLLEGE/ OFFICE<%}else{%>DIVISION/DEPT<%}%></font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">TENURESHIP</font></strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong><font size="1">SALARY</font></strong></div></td>
      <td width="5%" class="thinborder" align="center"><strong><font size="1">FINAL RATING</font></strong></td>
      <td width="5%" class="thinborder"><font size="1"><strong>RANK</strong></font></td>
    </tr>
    <%
	String[] astrConvertGender = {"M","F"};
for(int i = 0 ; i < vRetResult.size(); i +=14){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder"><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder">
        <% if(vRetResult.elementAt(i + 8) != null) {//outer loop.
	  		if(vRetResult.elementAt(i + 9) != null) {//inner loop.%>
        <%=(String)vRetResult.elementAt(i + 8)%>/<%=(String)vRetResult.elementAt(i + 9)%> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i + 8)%> 
        <%}//end of inner loop/
	  }else if(vRetResult.elementAt(i + 9) != null){//outer loop else%>
        <%=(String)vRetResult.elementAt(i + 9)%> 
        <%}%>
      </td>
      <td class="thinborder"> <div align="center">
	  <%=ConversionTable.differenceInYearMonthDaysNow((String)vRetResult.elementAt(i + 10))%></div></td>
      <td class="thinborder"> <div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 11),"&nbsp;")%></div></td>
      <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 13)%></td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>

<script>window.print();</script>
<%}//only if vRetResult not null
%>
 
</body>
</html>
<%
dbOP.cleanUP();
%>