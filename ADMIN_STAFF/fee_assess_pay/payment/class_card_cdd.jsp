<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector,java.sql.ResultSet" %>
<%
	WebInterface WI = new WebInterface(request);
	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.</font>
		<%
		return;
	}
	String strFontSize = WI.getStrValue(WI.fillTextValue("font_size"),"10")+"px";
	
	String strSubCodeToPrint = WI.fillTextValue("sub_c");
	
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css" media="print">
<!--
.container{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10pt;
	margin:0in 0in 0in 2in;	

}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10pt;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10pt;
}
<%if(!strSchoolCode.startsWith("AUF") && !strSchoolCode.startsWith("CGH")){%>
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
<%}%>
-->
</style>
</head>

<body onLoad="window.print();">

<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null;
	String strSubSecIndex = null;
	Vector vLabSched      = null;
	String strORNumber    = WI.fillTextValue("or_number");
	String strDegreeType  = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String[] astrSchYrInfo = {"0","0","0"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-assessedfees print(enrollment)","class_card.jsp");
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
							//							"assessedfees.jsp");
if(iAccessLevel == -1)//for fatal error.
{

	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
//end of authenticaion code.

if(strORNumber.length() ==0)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		OR Number can't be empty</font></p>
		<%
	dbOP.cleanUP();
	return;
}

Vector vStudInfo = null;
Vector vTemp = null;
Vector vORInfo = null;

String strCollegeName = null;

SubjectSection SS   = new SubjectSection();
FAPayment faPayment = new FAPayment();
FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAAssessment FA     = new FAAssessment();
EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();

Vector vAssessedSubDetail = null;

vORInfo = faPayment.viewPmtDetail(dbOP,strORNumber);
if(vORInfo == null || vORInfo.size() ==0)
{%>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=faPayment.getErrMsg()%></font></p>
  <%
	dbOP.cleanUP();
	return;
}

vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),
				(String)vORInfo.elementAt(25),(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vORInfo.elementAt(22));
if(vStudInfo == null) 
	strErrMsg = enrlStudInfo.getErrMsg();
else
{	
	/**
		vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
			(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
			(String)vORInfo.elementAt(22),"1",strDegreeType);
	**/					
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",(String)vStudInfo.elementAt(5), "degree_type"," and is_valid=1 and is_del=0");
	
	astrSchYrInfo[0] = (String)vORInfo.elementAt(23);
	astrSchYrInfo[1] = (String)vORInfo.elementAt(24);
	astrSchYrInfo[2] = (String)vORInfo.elementAt(22);

	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
	
	vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),false,
		(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
		(String)vORInfo.elementAt(22),"1",strDegreeType);
	if(vAssessedSubDetail == null || vAssessedSubDetail.size() ==0)
		strErrMsg = FA.getErrMsg();
		
	///remove here.. 
	if(strSubCodeToPrint.length() > 0) {
		for(int i = 0; i < vAssessedSubDetail.size(); i += 10) {
			if(strSubCodeToPrint.equals(vAssessedSubDetail.elementAt(i+1)))
				continue;
			vAssessedSubDetail.remove(i);vAssessedSubDetail.remove(i);vAssessedSubDetail.remove(i);
			vAssessedSubDetail.remove(i);vAssessedSubDetail.remove(i);vAssessedSubDetail.remove(i);
			vAssessedSubDetail.remove(i);vAssessedSubDetail.remove(i);vAssessedSubDetail.remove(i);
			vAssessedSubDetail.remove(i);
			i -= 10;
		}
	}	
		
}
%>
<% if(strErrMsg != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <th colspan="7" scope="col">
      <div align="center">
    <strong><%=strErrMsg%></strong></div>
    </th>
  </tr>
</table>
<%
	dbOP.cleanUP();
	return;
}if(vStudInfo != null && vStudInfo.size() > 0){
	String strSchedule = null;
	String strRoomAndSection = null; String strSection = null;
	String strLecLabStat = null;//0 = both,1 = lab, 2 = lec.
	Vector vSubSecDtls = new Vector();
	int iIndex = 0;
	
	java.sql.PreparedStatement pstmtGetLecLabStat = null;
	strTemp = "select IS_ONLY_LAB from enrl_final_cur_list where sub_sec_index=? and enrl_final_cur_list.is_valid = 1 and "+
				"user_index = "+(String)vStudInfo.elementAt(0)+" and IS_TEMP_STUD = 0";
	pstmtGetLecLabStat = dbOP.getPreparedStatement(strTemp);

	String strSQLQuery = "select date_enrolled from stud_curriculum_hist where user_index = "+ vStudInfo.elementAt(0) +
	"and sy_from = " + astrSchYrInfo[0]+ " and semester = "+astrSchYrInfo[2]+" and is_valid = 1";
	
	ResultSet rs = dbOP.executeQuery(strSQLQuery);
	strTemp = null;
	if(rs.next()){
		strTemp = WI.formatDate(rs.getDate(1), 10);
	}
	rs.close();
	if(vAssessedSubDetail != null && vAssessedSubDetail.size() > 0)
	{%> 
	  <%
		for(int i = 0; i< vAssessedSubDetail.size() ; ){
			if(i > 0) {%>
				<DIV style="page-break-before:always" >&nbsp;</DIV>
			<%}
		
			strSubSecIndex    = (String)vAssessedSubDetail.elementAt(i);
			strRoomAndSection = null;
			strSchedule       = null;
	//3 prints at once.
	%>	
    <div class="container">
	<div style="width:100%; margin:0px 0px 20px 0px">
  <div style="text-align:right"><%=WI.getTodaysDate(1)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
         <div style="padding:2px 0px 2px 95px;" >
		 <div style="padding:2px 0px 2px 0px;" ><%=(String)vORInfo.elementAt(25)%></div><!-- Stud ID -->
         <div style="padding:2px 0px 2px 0px;" ><%=(String)vStudInfo.elementAt(1)%></div><!-- Stud Name -->
         <div style="padding:2px 0px 2px 0px;" >
			<%=(String)vStudInfo.elementAt(16)%>
			<%if(vStudInfo.elementAt(6) != null){%> / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
			<%}%> - <%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%><!-- Course -->
		 </div>
        </div>
  </div>
  
<div  style="width:100%; margin:0px 0px 10px 0px">
<%	
	//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
	strTemp = (String)vAssessedSubDetail.elementAt(i+1);
	if(strTemp.indexOf("NSTP") != -1){
      iIndex = strTemp.indexOf("(");
      if(iIndex != -1){
        strTemp = strTemp.substring(0,iIndex);
        strTemp = strTemp.trim();
	  }
	}

	strLecLabStat = null;
	if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
		pstmtGetLecLabStat.setString(1,strSubSecIndex);
		rs = pstmtGetLecLabStat.executeQuery();
		if(rs.next())
			strLecLabStat = rs.getString(1);
		rs.close();
	}
		
	//get schedule here.
	if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") != 0) {
		vSubSecDtls = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);
		vLabSched   = SS.getLabSched(dbOP,strSubSecIndex);
	}else {
		vSubSecDtls = null;vLabSched = null;
	}
	if(vSubSecDtls == null || vSubSecDtls.size() ==0)
	{
		if(strSubSecIndex != null && strSubSecIndex.compareTo("-1") == 0) {//re-enrollment.
			vSubSecDtls = new Vector();
		}
		else {
			strErrMsg = SS.getErrMsg();
			break;
		}
	}
	for(int b=0; b<vSubSecDtls.size(); ++b)
	{
		if(strLecLabStat != null && strLecLabStat.compareTo("1") == 0)//lab only.
			continue;
		if(strRoomAndSection == null)
		{
			strSection = (String)vSubSecDtls.elementAt(b);
			strRoomAndSection = /*(String)vSubSecDtls.elementAt(b)+"/"+*/(String)vSubSecDtls.elementAt(b+1);
			strSchedule = (String)vSubSecDtls.elementAt(b+2);
		}
		else
		{
			strRoomAndSection += "| "+(String)vSubSecDtls.elementAt(b+1);
			strSchedule += "| "+(String)vSubSecDtls.elementAt(b+2);
		}
		b = b+2;
	}
	if(vLabSched != null)
	{
	  for (int p = 0; p < vLabSched.size(); ++p)
	  {
		  if(strLecLabStat != null && strLecLabStat.compareTo("2") == 0)//lec only.
			continue;
	    strSchedule += "| "+(String)vLabSched.elementAt(p+2) + "(lab)";
		strRoomAndSection += "| " + (String) vLabSched.elementAt(p + 1) + "(lab)";
		p = p+ 2;
	  }
	}
%> 
 
 	<div style="margin:5px 0px 0px 0px; padding:2px 0px 2px 95px;  width:100%; overflow:hidden;" >
		<div style="padding:1px 0px 1px 0px;" ><%=(String)vAssessedSubDetail.elementAt(i+1)%></div><!-- subj code -->
		<div style="padding:1px 0px 1px 0px; white-space: nowrap;" ><%=(String)vAssessedSubDetail.elementAt(i+2)%></div><!-- subj title -->
		<div style="padding:1px 0px 1px 0px;" ><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, <%=astrSchYrInfo[0]%> - <%=astrSchYrInfo[1]%></div>
		<div style="padding:1px 0px 1px 0px;" ><%=WI.getStrValue(strSection)%></div>
	</div>

	<div  style="width:100%; margin:20px 0px 0px 0px">
		<div style="padding:2px 0px 2px 95px;" >
		<%=WI.getStrValue(strSchedule,"N/A")%><!-- time --><br>
		<%=WI.getStrValue(strRoomAndSection,"N/A")%><!-- room -->		
		</div>
	</div>

</div>
</div>
<%i += 10;
if(i < vAssessedSubDetail.size() -4){%>

<%}
strRoomAndSection = null;
strSchedule = null;
}%>
<%
}//if vAssessedSubDetail no null

}//only if stud info is not null %>

</body>
</html>
<%
dbOP.cleanUP();
%>
