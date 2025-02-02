<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.CurriculumMaintenance,
	enrollment.FAAssessment,enrollment.SubjectSection,enrollment.EnrlAddDropSubject,java.util.Vector,java.sql.ResultSet" %>
<%
	WebInterface WI = new WebInterface(request);
	//I have to get the school code here.
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null) {
		%>
		<font style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px; color:#FF0000">
			You are already logged out. Please login again to access this page.
		<%
		return;
	}
	String strFontSize = WI.getStrValue(WI.fillTextValue("font_size"),"10")+"px";

if(strSchoolCode.startsWith("CDD")){%>
	<jsp:forward page="./class_card_cdd.jsp" />
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
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
{	vAssessedSubDetail = FA.getAssessSubDetailAfterOrBeforeEnrl(dbOP,(String)vStudInfo.elementAt(0),paymentUtil.isTempStud(),
			(String)vORInfo.elementAt(23),(String)vORInfo.elementAt(24),(String)vStudInfo.elementAt(4),
			(String)vORInfo.elementAt(22),"1",strDegreeType);
						
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
}
%>
<% if(strErrMsg != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <th height="30" colspan="7" scope="col">&nbsp;
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
	String strRoomAndSection = null;
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
			strSubSecIndex    = (String)vAssessedSubDetail.elementAt(i);
			strRoomAndSection = null;
			strSchedule       = null;
	//3 prints at once.
	%><br><br>	
  <table width="380" border="0" cellspacing="0" cellpadding="0" height="307">
  <tr>
    <td height="28" colspan="6">&nbsp;</td>
    </tr>
  <tr>
    <td height="21">&nbsp;</td>
    <td width="93" align="right"><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])].substring(0,1)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<!-- Term --></td>
    <td width="56"><%=astrSchYrInfo[0].substring(2,4)%></td>
    <td width="48"><!-- SY start -->
    <%=astrSchYrInfo[1].substring(2,4)%></td>
    <td width="34"><!-- SY ends --></td>
    <td width="59">&nbsp;</td>
  </tr>
  <tr>
    <td height="54">&nbsp;</td>
    <td colspan="5" style="font-weight:bold"><%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP,request,strSubSecIndex ,astrSchYrInfo[0],astrSchYrInfo[2],"PHILCST"), "&nbsp;")%></td>
  </tr>
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vORInfo.elementAt(25)%><!-- Stud ID --></td>
  </tr>
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5" style="font-weight:bold"><%=(String)vStudInfo.elementAt(1)%><!-- Stud Name --></td>
  </tr>
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vStudInfo.elementAt(16)%>
	<%if(vStudInfo.elementAt(6) != null){%>
      / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
    <%}%> - <%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%><!-- Course --></td>
  </tr> 
  <tr>
  	<td colspan="6" height="20"></td>
  </tr>
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
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vAssessedSubDetail.elementAt(i+1)%><!-- subj code --></td>
  </tr>  
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vAssessedSubDetail.elementAt(i+2)%><!-- subj title --></td>
  </tr>
  <tr>
  	<td colspan="6" height="20"></td>
  </tr>    
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=WI.getStrValue(strSchedule,"N/A")%><!-- time --></td>
  </tr>   
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=WI.getStrValue(strRoomAndSection,"N/A")%><!-- room --></td>
  </tr>
  <tr>
  	<td height="100%">&nbsp;</td>
  	<td colspan="5">&nbsp;</td>
  </tr>
</table>
<%i += 10;
  if( i < vAssessedSubDetail.size() - 4) {
  	strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);
	strRoomAndSection = null;
	strSchedule       = null;
	%><br><br><br>
  <table width="380" border="0" cellspacing="0" cellpadding="0" height="307">
  <tr>
    <td height="28" colspan="6">&nbsp;</td>
    </tr>
  <tr>
    <td height="21">&nbsp;</td>
    <td width="93" align="right"><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])].substring(0,1)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<!-- Term --></td>
    <td width="52"><%=astrSchYrInfo[0].substring(2,4)%></td>
    <td width="52"><!-- SY start -->
    <%=astrSchYrInfo[1].substring(2,4)%></td>
    <td width="34"><!-- SY ends --></td>
    <td width="59">&nbsp;</td>
  </tr>
  <tr>
    <td height="54">&nbsp;</td>
    <td colspan="5" style="font-weight:bold"><%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP,request,strSubSecIndex ,astrSchYrInfo[0],astrSchYrInfo[2],"PHILCST"), "&nbsp;")%></td>
  </tr>
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vORInfo.elementAt(25)%><!-- Stud ID --></td>
  </tr>
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5" style="font-weight:bold"><%=(String)vStudInfo.elementAt(1)%><!-- Stud Name --></td>
  </tr>
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vStudInfo.elementAt(16)%>
	<%if(vStudInfo.elementAt(6) != null){%>
      / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
    <%}%> - <%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%><!-- Course --></td>
  </tr> 
  <tr>
  	<td colspan="6" height="20"></td>
  </tr>
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
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vAssessedSubDetail.elementAt(i+1)%><!-- subj code --></td>
  </tr>  
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vAssessedSubDetail.elementAt(i+2)%><!-- subj title --></td>
  </tr>
  <tr>
  	<td colspan="6" height="20"></td>
  </tr>    
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=WI.getStrValue(strSchedule,"N/A")%><!-- time --></td>
  </tr>   
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=WI.getStrValue(strRoomAndSection,"N/A")%><!-- room --></td>
  </tr>
  <tr>
  	<td height="100%">&nbsp;</td>
  	<td colspan="5">&nbsp;</td>
  </tr>
</table>
<% i += 10;}
  if( i < vAssessedSubDetail.size() - 4) {
  	strSubSecIndex = (String)vAssessedSubDetail.elementAt(i);
	strRoomAndSection = null;
	strSchedule       = null;%><br><br><br>	
  <table width="380" border="0" cellspacing="0" cellpadding="0" height="307">
  <tr>
    <td height="28" colspan="6">&nbsp;</td>
    </tr>
  <tr>
    <td height="21">&nbsp;</td>
    <td width="93" align="right"><%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])].substring(0,1)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<!-- Term --></td>
    <td width="55"><%=astrSchYrInfo[0].substring(2,4)%></td>
    <td width="49"><!-- SY start -->
    <%=astrSchYrInfo[1].substring(2,4)%></td>
    <td width="34"><!-- SY ends --></td>
    <td width="59">&nbsp;</td>
  </tr>
  <tr>
    <td height="54">&nbsp;</td>
    <td colspan="5" style="font-weight:bold"><%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP,request,strSubSecIndex ,astrSchYrInfo[0],astrSchYrInfo[2],"PHILCST"), "&nbsp;")%></td>
  </tr>
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vORInfo.elementAt(25)%><!-- Stud ID --></td>
  </tr>
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5" style="font-weight:bold"><%=(String)vStudInfo.elementAt(1)%><!-- Stud Name --></td>
  </tr>
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vStudInfo.elementAt(16)%>
	<%if(vStudInfo.elementAt(6) != null){%>
      / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
    <%}%> - <%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%><!-- Course --></td>
  </tr> 
  <tr>
  	<td colspan="6" height="20"></td>
  </tr>
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
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vAssessedSubDetail.elementAt(i+1)%><!-- subj code --></td>
  </tr>  
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=(String)vAssessedSubDetail.elementAt(i+2)%><!-- subj title --></td>
  </tr>
  <tr>
  	<td colspan="6" height="20"></td>
  </tr>    
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=WI.getStrValue(strSchedule,"N/A")%><!-- time --></td>
  </tr>   
  <tr>
	 <td width="90">&nbsp;</td>  	
     <td colspan="5"><%=WI.getStrValue(strRoomAndSection,"N/A")%><!-- room --></td>
  </tr>
  <tr>
  	<td height="100%">&nbsp;</td>
  	<td colspan="5">&nbsp;</td>
  </tr>
</table>
<%i += 10;}
if(i < vAssessedSubDetail.size() -4){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%};
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
