<%@ page language="java" import="utility.*, osaGuidance.GDPsychologicalTestReport, osaGuidance.GDPsychologicalTest, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
	function ReloadPage(){
		document.form_.submit();
	}
	
	function PrintPage(){
	
		if(!confirm("Click OK to print report"))
			return;
	
		document.bgColor = "#FFFFFF";

		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		
		document.getElementById("myADTable2").deleteRow(0);
		document.getElementById("myADTable3").deleteRow(0);
		document.getElementById("myADTable3").deleteRow(0);
		
		window.print();
	}

</script>
</head>
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","test_reports.jsp");
	
	String strErrMsg = null;
	String strTemp = null;
	
	Vector vRetResult = null;
	Vector vClassificationList = null;
	Vector vFactorList = null;
	
	GDPsychologicalTestReport PsychTestReport = new GDPsychologicalTestReport();
	GDPsychologicalTest PsychTest = new GDPsychologicalTest();
	
	
	boolean bolShowGender = (WI.fillTextValue("show_gender").equals("1"));
	boolean bolShowTotal  = (WI.fillTextValue("show_total").equals("1"));
	
	Vector vPsyTestList = PsychTest.operateOnPsyTestName(dbOP, request, 4);
	if(vPsyTestList == null)
		strErrMsg = PsychTest.getErrMsg();
		
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSem = WI.fillTextValue("semester");
	String strCourseIndex = WI.fillTextValue("course_index");
	String strCIndex = WI.fillTextValue("c_index");
	String strCourseName = null;
	
	java.sql.ResultSet rs = null;
	
	/*Vector vCourseList = new Vector();
	if(strCourseIndex.length() > 0)
		vCourseList.addElement(strCourseIndex);
	else{
		strTemp = "select course_index  from course_offered where is_valid =1 and is_offered = 1 ";
		if(strCIndex.length() > 0)
			strTemp += " and c_index = "+strCIndex;
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			vCourseList.addElement(rs.getString(1));
		}rs.close();
	}*/
	
	

	strTemp = "select course_name from course_offered where course_index = ?";
	java.sql.PreparedStatement pstmtGetCName = dbOP.getPreparedStatement(strTemp);
	
	strTemp = "select c_name from college where c_index = ?";
	java.sql.PreparedStatement pstmtGetColName = dbOP.getPreparedStatement(strTemp);

		
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./test_reports_UB.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING - PSYCHOLOGICAL TEST REPORTS::::</strong></font></div></td>
    </tr>

	<tr><td height="25">&nbsp;</td>
	  <td height="25" colspan="5"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
	<tr>
		<td width="3%" height="30">&nbsp;</td>
		<td width="12%">School Year</td>
		<td width="17%" valign="middle">
		<%
		strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); 
		%> 
		<input name="sy_from" type="text" size="4" maxlength="4"  
			value="<%=strTemp%>" class="textbox" onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
		to 
		<%
		strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); 
		%> 
		<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">	  </td>
		<td width="6%" valign="middle">Term </td>
		<td width="18%" valign="middle">
		<%
		strTemp = WI.fillTextValue("semester");
		%>
		<select name="semester" style="font-size:11px">
			<option value="">N/A</option>
		<%
		if(strTemp.equals("0"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="0" <%=strErrMsg%>>Summer</option>
		
		<%
		if(strTemp.equals("1"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="1" <%=strErrMsg%>>1st Sem</option>
		
		<%
		if(strTemp.equals("2"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="2" <%=strErrMsg%>>2nd Sem</option>
		
		<%
		if(strTemp.equals("3"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="3" <%=strErrMsg%>>3rd Sem</option>
		</select>	  </td>
		<td width="44%" valign="middle">
			<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
	</tr>
	<tr>
	    <td height="30">&nbsp;</td>
	    <td>College</td>
	    <td colspan="4" valign="middle">
		<select name="c_index" style="width:400px;" onChange="ReloadPage();">
			<option value="">Please select college</option>
			<%=dbOP.loadCombo("c_index"," c_name"," from college where is_del =0 order by c_name", WI.fillTextValue("c_index"), false)%>
		</select>
		</td>
	    </tr>
	<tr>
	  <td height="30">&nbsp;</td>
	  <td>Course</td>
	  <td colspan="4" valign="middle">
	  	<select name="course_index" style="width:400px;">
		<%if(WI.fillTextValue("c_index").length() > 0){%><option value="">Select All</option><%}%>
		<%
		strTemp = " from course_offered where is_valid =1 and is_offered = 1 ";
		if(WI.fillTextValue("c_index").length() > 0)
			strTemp += " and c_index = "+WI.fillTextValue("c_index");
		strTemp += " order by course_name ";
		%>
			<%=dbOP.loadCombo("course_index"," course_code + ' ::: '+ course_name", strTemp, WI.fillTextValue("course_index"), false)%>
		</select>	  </td>
    </tr>
	<tr>
	  <td height="30">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td colspan="4" valign="middle">
	  <%
		strTemp = WI.fillTextValue("show_gender");
		if(strTemp.equals("1"))
		  	strErrMsg = "checked";
		else
			strErrMsg = "";
	  %>
	  	<input type="checkbox" name="show_gender" value="1" <%=strErrMsg%>>Gender
	<%
		strTemp = WI.fillTextValue("show_total");
		if(strTemp.equals("1"))
		  	strErrMsg = "checked";
		else
			strErrMsg = "";
	%>
		<input type="checkbox" name="show_total" value="1" <%=strErrMsg%>>Total	  </td>
    </tr>
	<%	
	if(vPsyTestList != null && vPsyTestList.size() > 0){%>
	<tr><td colspan="2">&nbsp;</td><td colspan="4" height="30"><strong>PSYCHOLOGICAL TEST LIST</strong></td></tr>
	
	
	<tr>
		<td colspan="2">&nbsp;</td>
		<td colspan="4">
			<%
			for(int i = 0; i < vPsyTestList.size(); i+=4){
			
				strTemp = WI.fillTextValue("test_name_index_"+i/4);
				if(strTemp.length() > 0)
					strErrMsg = "checked";
				else
					strErrMsg = "";
			
			%>
			<input type="checkbox" name="test_name_index_<%=i/4%>" value="<%=vPsyTestList.elementAt(i)%>" <%=strErrMsg%>><%=vPsyTestList.elementAt(i+1)%><br>
			<%}%>		</td>
	</tr>
	<%
	}%>
	<tr><td height="19" colspan="6">&nbsp;</td></tr>
</table>

<%

int iTableWidth = 0;
int iTableNo = 0;
int iTemp = 0;
double dTemp = 0d;

int iMale = 0;
int iFemale = 0;
int iIndexOf = 0;

int iSubTotal = 0;

int iTotalMale = 0;
int iTotalFemale = 0;

boolean bolShowPrint = false;


if(vPsyTestList != null && vPsyTestList.size() > 0){



//while(vCourseList.size() > 0)

//strCourseIndex  = (String)vCourseList.remove(0);


for(int i = 0; i < vPsyTestList.size(); i+=4){
	if(WI.fillTextValue("test_name_index_"+i/4).length() == 0)
		continue;

	vRetResult = PsychTestReport.getPsychologicalTestReport(dbOP, request, WI.fillTextValue("test_name_index_"+i/4), strSYFrom, strSem, strCourseIndex);
	if(vRetResult == null || vRetResult.size() == 0)
		continue;
	
	pstmtGetCName.setString(1, strCourseIndex);
	rs = pstmtGetCName.executeQuery();
	strCourseName = null;
	if(rs.next())
		strCourseName = rs.getString(1);
	rs.close();
	
	if(strCourseName == null || strCourseName.length() == 0){
		pstmtGetColName.setString(1, strCIndex);
		rs = pstmtGetColName.executeQuery();
		strCourseName = null;
		if(rs.next())
			strCourseName = rs.getString(1);
		rs.close();
	}
	
	
		vFactorList = (Vector)vRetResult.remove(0);
		vClassificationList = (Vector)vRetResult.remove(0);
		
		bolShowPrint = true;
%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<%if(i > 0){%><tr><td>&nbsp;</td></tr><%}%>
	<tr><td align="center">Table <%=++iTableNo%>.</td></tr>
	<tr><td align="center">
		Frequency and Percentage Distribution of First Year <%=WI.getStrValue(strCourseName)%> Students According to their <%=(String)vPsyTestList.elementAt(i+3)%>
	</td></tr>
</table>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td height="25" class="thinborder">&nbsp;</td>
		<%
		if(bolShowGender)
	  		iTemp = vClassificationList.size() * 4;
		else
			iTemp = vClassificationList.size() * 2;
		%>
		<td colspan="<%=iTemp%>" align="center" class="thinborder">CLASSIFICATION</td>
		
		<%
		if(bolShowTotal){
		%>
		<td rowspan="2" colspan="<%=iTemp%>" class="thinborder" align="center">TOTAL</td>
		<%}%>
	</tr>
	<tr>
		<td class="thinborder" height="25">&nbsp;</td>
	  <%
	  	if(bolShowGender)
	  		iTemp = 4;
		else
			iTemp = 2;
			
		for(int j = 0; j < vClassificationList.size(); j++){
	  %>
	  <td class="thinborder" colspan="<%=iTemp%>" align="center"><%=vClassificationList.elementAt(j)%></td>
	  	<%}%>
    </tr>
	<tr>
		<td class="thinborder" height="25" align="center">FACTOR</td>
		<%
		for(int j = 0; j < vClassificationList.size(); j++){
	  	if(bolShowGender){
	  	%>
	  	<td class="thinborder" align="center">M</td>
	  	<td class="thinborder" align="center">F</td>
	  	<td class="thinborder" align="center">T</td>
	  	<td class="thinborder" align="center">%</td>
	  	<%}else{%>
	  	<td class="thinborder" align="center">F</td>
	  	<td class="thinborder" align="center">T</td>
	  	<%}
	  	}//end for loop%>
	  
	  	<%
		if(bolShowTotal){		
		if(bolShowGender){
	  	%>
	  	<td class="thinborder" align="center">M</td>
	  	<td class="thinborder" align="center">F</td>
	  	<td class="thinborder" align="center">T</td>
	  	<td class="thinborder" align="center">%</td>
	  	<%}else{%>
	  	<td class="thinborder" align="center">F</td>
	  	<td class="thinborder" align="center">T</td>
	  	<%}
		}%>
    </tr>
	
<%

for(int k = 0; k < vFactorList.size(); k+=2){
	strTemp = (String)vFactorList.elementAt(k);
	iSubTotal = Integer.parseInt((String)vFactorList.elementAt(k+1));
	
	iTotalMale = 0;
	iTotalFemale = 0;
%>	
	<tr>
	    <td class="thinborder" height="25" align="center"><%=vFactorList.elementAt(k)%></td>
		<%
		for(int j = 0; j < vClassificationList.size(); j++){
			strErrMsg = (String)vClassificationList.elementAt(j);
		
		if(bolShowGender){
			iTableWidth = 3;
			//for male
			iMale = 0;
			iIndexOf = vRetResult.indexOf(strTemp+strErrMsg+"M");
			if(iIndexOf > -1)
				iMale = Integer.parseInt((String)vRetResult.elementAt(iIndexOf + 1));
				
			iFemale = 0;
			iIndexOf = vRetResult.indexOf(strTemp+strErrMsg+"F");
			if(iIndexOf > -1)
				iFemale = Integer.parseInt((String)vRetResult.elementAt(iIndexOf + 1));
				
			iTotalMale += iMale;
			iTotalFemale += iFemale;
			
			dTemp = PsychTestReport.getPercentage((double)(iFemale + iMale), (double)iSubTotal, 100);
		%>
		<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=iMale%></td>
		<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=iFemale%></td>
		<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=iFemale + iMale%></td>		
		<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		<%}else{
		iTableWidth = 5;
		iFemale = 0;
		iIndexOf = vRetResult.indexOf(strTemp+strErrMsg);
		if(iIndexOf > -1)
			iFemale = Integer.parseInt((String)vRetResult.elementAt(iIndexOf + 1));
			
		dTemp = PsychTestReport.getPercentage((double)iFemale, (double)iSubTotal, 100);
		%>
		<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=iFemale%></td>
		<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=CommonUtil.formatFloat(dTemp, true)%></td>
		<%}
		}//end for loop%>
		
		<%
		if(bolShowTotal){		
		if(bolShowGender){iTableWidth = 3;
	  	%>
	  	<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=iTotalMale%></td>
	  	<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=iTotalFemale%></td>
		<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=iSubTotal%></td>		
		<td class="thinborder" align="center" width="<%=iTableWidth%>%">100</td>
	  	<%}else{iTableWidth = 5;%>
	  	<td class="thinborder" align="center" width="<%=iTableWidth%>%"><%=iSubTotal%></td>
		<td class="thinborder" align="center" width="<%=iTableWidth%>%">100</td>
	  	<%}
		}%>
	 </tr>
<%}%>
</table>
 


<%}//end of for loop

if(bolShowPrint){
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
	<tr><td align="right">
		<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
	</td></tr>
</table>
<%}
}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
	<tr><td height="25"  colspan="3">&nbsp;</td></tr>
	<tr><td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
 
</form>
</body>
</html>
<%
PsychTestReport.removeTempTable(dbOP);
dbOP.cleanUP();
%>