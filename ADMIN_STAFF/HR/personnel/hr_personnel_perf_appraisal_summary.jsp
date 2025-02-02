<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTamiya" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Performance Appraisal Summary</title>
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
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

	function PrintPg(){
		if(document.form_.rp_index.value.length == 0){
			alert("Please provide appraisal period informatio.");
			return;
		}
	
		document.form_.view_summary.value = "";
		document.form_.print_page.value = "1";
		document.form_.submit();
	}

	function ViewSummary(){
		if(document.form_.rp_index.value.length == 0){
			alert("Please provide appraisal period information.");
			return;
		}
		
		document.form_.view_summary.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		this.processRequest(strURL);
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./hr_personnel_perf_appraisal_summary_print.jsp" />
	<% 
		return;}
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	
	if (bolMyHome)
		iAccessLevel = 2;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Notice of Action","hr_personnel_perf_appraisal_summary.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	double dTemp = 0d;
	double dRowSum = 0d;
	Vector vValues = null;
	Vector vRetResult = null;
	HRTamiya tamiya = new HRTamiya();	
	
	if(WI.fillTextValue("view_summary").length() > 0){
		vRetResult = tamiya.generateAppraisalSummary(dbOP, request);
		if(vRetResult == null)
			strErrMsg = tamiya.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="hr_personnel_perf_appraisal_summary.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: PERFORMANCE APPRAISAL SUMMARY ::::</strong></font></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Appraisal Period:</td>
			<td width="80%">
				<select name="rp_index">
					<option value="">Select Appraisal Period</option>
					<%=dbOP.loadCombo("rp_index","rp_title"," from hr_lhs_review_period where is_valid = 1 "+
						"order by period_open_fr desc ",WI.fillTextValue("rp_index"),false)%>
				</select></td>
		</tr>
		<%
			String strCollegeIndex = WI.fillTextValue("c_index");
		%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>:</td>
			<td>
				<select name="c_index" onChange="loadDept();">
          			<option value="0">ALL</option>
          			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        		</select></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department: </td>
			<td>
				<label id="load_dept">
				<select name="d_index">
         			<option value="">ALL</option>
          		<%if ((strCollegeIndex.length() == 0) || strCollegeIndex.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
         		 <%}%>
  	   			</select>
				</label></td>
        </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td><a href="javascript:ViewSummary();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to view performance appraisal summary.</font></td>
	    </tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a></td>
		</tr>
	</table>
	<%for(int i = 0; i < vRetResult.size(); i+=7){
		double dSum[] = new double[5];
		double dOverall = 0d;
		int iCount1 = 0;
		int iCount2 = 0;
		int iCount3 = 0;
		int iCount4 = 0; 
		int iCount5 = 0;
		int iTotCount = 0;
		vValues = (Vector)vRetResult.elementAt(i+6);
		
		if(i > 0){
	%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<%}%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" class="thinborder" width="20%">
				<%=WI.getStrValue((String)vRetResult.elementAt(i+2), "DIV: ", "", "")%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "<br>DEPT: ", "", "")%>
				<%
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5), (String)vRetResult.elementAt(i+4));
				%>
				<%=WI.getStrValue(strTemp, "<br>(",  ")", "")%>
			</td>
	        <td align="center" class="thinborder" width="12%">JOB<br>KNOWLEDGE</td>
	        <td align="center" class="thinborder" width="12%">QUALITY<br>OF WORK </td>
	        <td align="center" class="thinborder" width="12%">QUANTITY<br>OF WORK </td>
	        <td align="center" class="thinborder" width="12%">ATTENDANCE</td>
	        <td align="center" class="thinborder" width="20%">ATTITUDE TOWARD<br>WORK &amp; THE COMPANY </td>
	        <td align="center" class="thinborder" width="12%">TOTAL/<br>AVERAGE</td>
		</tr>
		<%for(int j = 0; j < vValues.size(); j += 6){
			dRowSum = 0;
		%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vValues.elementAt(j)%></td>
			<%
				strTemp = (String)vValues.elementAt(j+1);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*20);
					dSum[0] += (dTemp*20);
					iCount1++;
					strTemp = CommonUtil.formatFloat(dTemp*20, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vValues.elementAt(j+2);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*15);
					dSum[1] += (dTemp*15);
					iCount2++;
					strTemp = CommonUtil.formatFloat(dTemp*15, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vValues.elementAt(j+3);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*15);
					dSum[2] += (dTemp*15);
					iCount3++;
					strTemp = CommonUtil.formatFloat(dTemp*15, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vValues.elementAt(j+4);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*30);
					dSum[3] += (dTemp*30);
					iCount4++;
					strTemp = CommonUtil.formatFloat(dTemp*30, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vValues.elementAt(j+5);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*20);
					dSum[4] += (dTemp*20);
					iCount5++;
					strTemp = CommonUtil.formatFloat(dTemp*20, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(dRowSum == 0)
					strTemp = "&nbsp;";
				else{
					iTotCount++;
					dOverall += dRowSum/100;
					strTemp = CommonUtil.formatFloat(dRowSum/100, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
		<%}%>
		<tr>
			<td height="25" class="thinborder">TOTAL</td>
			<%
				if(iCount1 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[0]/iCount1, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iCount2 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[1]/iCount2, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iCount3 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[2]/iCount3, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iCount4 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[3]/iCount4, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iCount5 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[4]/iCount5, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iTotCount == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dOverall/iTotCount, 1);
			%>			
		    <td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
	</table>
	<%}
}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="view_summary">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>