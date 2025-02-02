<%@ page language="java" import="utility.*,enrollment.CreditEvaluation,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Credit Evaluation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	//// - all about ajax.. 
	function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.temp_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_temp=1&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.temp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing
	}
	
	function UpdateNameFormat(strName) {
		//do nothing
	}
	
	function SearchSubjects(){
		document.form_.print_page.value = "";
		document.form_.search_subjects.value = "1";
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.temp_id.focus();
	}
	
	function SaveCredEval(){
		document.form_.save_cred_eval.value = "1";
		this.SearchSubjects();
	}
	
	function PrintPage(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;	
	String strTemp = null;
	String strErrMsg = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./credit_eval_print.jsp" />
	<% 
		return;}
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CREDIT EVALUATION-CREDIT EVALUATION","credit_eval.jsp");
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
															"Enrollment","CREDIT EVALUATION",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission","Registration",request.getRemoteAddr(),
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
	
	String strEvaluatedBy = null;
	String strComment = null;
	String strCreateTime = null;
	String[] astrYear = {"", "First Year", "Second Year", "Third Year", "Fourth Year", "Fifth Year", "Sixth Year", "Seventh Year", "Eigth Year"};
	String[] astrSemester = {"Summer", "First Semester", "Second Semester", "Third Semester"};
	boolean bolHasEntry = false;
	Vector vInfo = null;
	Vector vSubjects = null;
	CreditEvaluation ce = new CreditEvaluation();
	
	if(WI.fillTextValue("search_subjects").length() > 0){
		vInfo = ce.getTempStudInfo(dbOP, request);
		if(vInfo == null)
			strErrMsg = ce.getErrMsg();
		else{
			if(WI.fillTextValue("save_cred_eval").length() > 0){
				if(!ce.operateOnSubjCreditEval(dbOP, request))
					strErrMsg = ce.getErrMsg();
				else
					strErrMsg = "Operation successful.";
			}
		
			vSubjects = ce.getSubjsForCredEval(dbOP, request, vInfo);
			if(vSubjects == null)
				ce.getErrMsg();
			else{
				strEvaluatedBy = (String)vSubjects.remove(0);
				strCreateTime = (String)vSubjects.remove(0);
				strComment = WI.getStrValue((String)vSubjects.remove(0));
			}
		}
	}	
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./credit_eval.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
			  <font color="#FFFFFF"><strong>:::: CREDIT EVALUATION ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Temp ID: </td>
			<td width="80%" valign="top">
				<input name="temp_id" type="text" size="16" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('1');" value="<%=WI.fillTextValue("temp_id")%>">&nbsp;
				<label id="coa_info" style="position:absolute; width:300px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:SearchSubjects();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vInfo != null && vInfo.size() > 0){%>
	<input type="hidden" name="application_index" value="<%=(String)vInfo.elementAt(0)%>">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Name:</td>
			<td width="30%"><%=(String)vInfo.elementAt(1)%></td>
			<td width="17%">SY/Term:</td>
			<td width="33%"><%=(String)vInfo.elementAt(4)%> - <%=(String)vInfo.elementAt(5)%> / <%=astrSemester[Integer.parseInt((String)vInfo.elementAt(6))]%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>ID:</td>
			<td><%=WI.fillTextValue("temp_id")%></td>
			<td>Curriculum Year: </td>
			<td><%=(String)vInfo.elementAt(7)%> - <%=(String)vInfo.elementAt(8)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course:</td>
			<td><%=(String)vInfo.elementAt(10)%></td>
			<td>Application Catg: </td>
			<td><%=(String)vInfo.elementAt(9)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Major:</td>
			<td colspan="3"><%=WI.getStrValue((String)vInfo.elementAt(12))%></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
<%}

int iCount = 1;
boolean bolChange = false;
Vector vTemp = null;
Vector vFirst = null;
Vector vSecond = null;
Vector vSummer = null;

String strSubIndex = null;
String strSubCode = null;
String strSubName = null;
String strLecUnit = null;
String strLabUnit = null;
String strYear = null;
String strSemester = null;
String strStatus = null;
String strCurrentSem = null;

double dLecUnit = 0d;
double dLabUnit = 0d;

if(vSubjects != null && vSubjects.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%for(int i = 0; i < vSubjects.size(); i += 2){
		vFirst = new Vector();
		vSecond = new Vector();
		vSummer = new Vector();
		vTemp = (Vector)vSubjects.elementAt(i+1);
		while(vTemp.size() > 0){
			strTemp = (String)vTemp.elementAt(6);//semester
			if(strTemp.equals("2")){//if 2nd sem
				vSecond.addElement((String)vTemp.remove(0));vSecond.addElement((String)vTemp.remove(0));
				vSecond.addElement((String)vTemp.remove(0));vSecond.addElement((String)vTemp.remove(0));
				vSecond.addElement((String)vTemp.remove(0));vSecond.addElement((String)vTemp.remove(0));
				vSecond.addElement((String)vTemp.remove(0));vSecond.addElement((String)vTemp.remove(0));
			}
			else if(strTemp.equals("1")){//if first sem and summer
				vFirst.addElement((String)vTemp.remove(0));vFirst.addElement((String)vTemp.remove(0));
				vFirst.addElement((String)vTemp.remove(0));vFirst.addElement((String)vTemp.remove(0));
				vFirst.addElement((String)vTemp.remove(0));vFirst.addElement((String)vTemp.remove(0));
				vFirst.addElement((String)vTemp.remove(0));vFirst.addElement((String)vTemp.remove(0));
			}
			else{
				vSummer.addElement((String)vTemp.remove(0));vSummer.addElement((String)vTemp.remove(0));
				vSummer.addElement((String)vTemp.remove(0));vSummer.addElement((String)vTemp.remove(0));
				vSummer.addElement((String)vTemp.remove(0));vSummer.addElement((String)vTemp.remove(0));
				vSummer.addElement((String)vTemp.remove(0));vSummer.addElement((String)vTemp.remove(0));
			}
		}
	%>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td width="5%">&nbsp;</td>
			<td width="43%" valign="top">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<%
				dLecUnit = 0d;
				dLabUnit = 0d;
				bolHasEntry = false;
				while(vFirst.size() > 0){
					bolHasEntry = true;
					iCount++;
					bolChange = false;
					strSubIndex = (String)vFirst.remove(0);
					strSubCode = (String)vFirst.remove(0);
					strSubName = (String)vFirst.remove(0);
					strLecUnit = (String)vFirst.remove(0);
					strLabUnit = (String)vFirst.remove(0);
					strYear = (String)vFirst.remove(0);
					strSemester = (String)vFirst.remove(0);
					strStatus = WI.getStrValue((String)vFirst.remove(0));
					
					if(strCurrentSem == null){
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					if(!strCurrentSem.equals(strSemester)){					
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					dLecUnit += Double.parseDouble(strLecUnit);
					dLabUnit += Double.parseDouble(strLabUnit);
				%>
					<input type="hidden" name="sub_index_<%=iCount%>" value="<%=strSubIndex%>">
				<%if(bolChange){%>
					<tr>
						<td height="25" colspan="3" align="center">
							<u><%=astrYear[Integer.parseInt(strYear)]%> - <%=astrSemester[Integer.parseInt(strSemester)]%></u></td>
					</tr>
				<%}%>
					<tr>
						<td height="25" width="10%">
							<select name="status_<%=iCount%>">
								<option value=""></option>
							<%if(strStatus.equals("1")){%>
								<option value="1" selected>C</option>
							<%}else{%>
								<option value="1">C</option>
							
							<%}if(strStatus.equals("2")){%>
								<option value="2" selected>T</option>
							<%}else{%>
								<option value="2">T</option>
							
							<%}if(strStatus.equals("3")){%>
								<option value="3" selected>P</option>
							<%}else{%>
								<option value="3">P</option>
							<%}%>
							</select>							</td>
						<td width="70%"><%=strSubCode%> - <%=strSubName%></td>
						<td width="20%" align="right"><%=strLecUnit%>/<%=strLabUnit%></td>
					</tr>
				<%}
				if(bolHasEntry){%>
					<tr>
						<td height="25" colspan="2">&nbsp;</td>
						<td class="thinborderTOP" align="right"><font style="font-size:12px"><%=dLecUnit%>/<%=dLabUnit%></font></td>
					</tr>
				<%}
				dLecUnit = 0d;
				dLabUnit = 0d;
				bolHasEntry = false;
				while(vSummer.size() > 0){
					bolHasEntry = true;
					iCount++;
					bolChange = false;
					strSubIndex = (String)vSummer.remove(0);
					strSubCode = (String)vSummer.remove(0);
					strSubName = (String)vSummer.remove(0);
					strLecUnit = (String)vSummer.remove(0);
					strLabUnit = (String)vSummer.remove(0);
					strYear = (String)vSummer.remove(0);
					strSemester = (String)vSummer.remove(0);
					strStatus = WI.getStrValue((String)vSummer.remove(0));
					
					if(strCurrentSem == null){
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					if(!strCurrentSem.equals(strSemester)){					
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					dLecUnit += Double.parseDouble(strLecUnit);
					dLabUnit += Double.parseDouble(strLabUnit);
				%>
					<input type="hidden" name="sub_index_<%=iCount%>" value="<%=strSubIndex%>">
				<%if(bolChange){%>
					<tr>
						<td height="15" colspan="3" align="center">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" colspan="3" align="center">
							<u><%=astrYear[Integer.parseInt(strYear)]%> - <%=astrSemester[Integer.parseInt(strSemester)]%></u></td>
					</tr>
				<%}%>
					<tr>
						<td height="25" width="10%">
							<select name="status_<%=iCount%>">
								<option value=""></option>
							<%if(strStatus.equals("1")){%>
								<option value="1" selected>C</option>
							<%}else{%>
								<option value="1">C</option>
							
							<%}if(strStatus.equals("2")){%>
								<option value="2" selected>T</option>
							<%}else{%>
								<option value="2">T</option>
							
							<%}if(strStatus.equals("3")){%>
								<option value="3" selected>P</option>
							<%}else{%>
								<option value="3">P</option>
							<%}%>
							</select>							</td>
						<td width="70%"><%=strSubCode%> - <%=strSubName%></td>
						<td width="20%" align="right"><%=strLecUnit%>/<%=strLabUnit%></td>
					</tr>
				<%}
				if(bolHasEntry){%>
					<tr>
						<td height="25" colspan="2">&nbsp;</td>
						<td class="thinborderTOP" align="right"><font style="font-size:12px"><%=dLecUnit%>/<%=dLabUnit%></font></td>
					</tr>
				<%}%>
				</table></td>
			<td width="4%">&nbsp;</td>
			<td width="43%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
				<%
				strCurrentSem = null;
				dLecUnit = 0d;
				dLabUnit = 0d;
				bolHasEntry = false;
				while(vSecond.size() > 0){
					bolHasEntry = true;
					iCount++;
					bolChange = false;
					strSubIndex = (String)vSecond.remove(0);
					strSubCode = (String)vSecond.remove(0);
					strSubName = (String)vSecond.remove(0);
					strLecUnit = (String)vSecond.remove(0);
					strLabUnit = (String)vSecond.remove(0);
					strYear = (String)vSecond.remove(0);
					strSemester = (String)vSecond.remove(0);
					strStatus = WI.getStrValue((String)vSecond.remove(0));
					
					dLecUnit += Double.parseDouble(strLecUnit);
					dLabUnit += Double.parseDouble(strLabUnit);
					
					if(strCurrentSem == null){
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					if(!strCurrentSem.equals(strSemester)){
						strCurrentSem = strSemester;
						bolChange = true;
					}
				%>
					<input type="hidden" name="sub_index_<%=iCount%>" value="<%=strSubIndex%>">
				<%if(bolChange){%>
					<tr>
						<td height="25" colspan="3" align="center">
							<u><%=astrYear[Integer.parseInt(strYear)]%> - <%=astrSemester[Integer.parseInt(strSemester)]%></u>
						</td>
					</tr>
				<%}%>
					<tr>
						<td height="25" width="10%">
							<select name="status_<%=iCount%>">
								<option value=""></option>
							<%if(strStatus.equals("1")){%>
								<option value="1" selected>C</option>
							<%}else{%>
								<option value="1">C</option>
							
							<%}if(strStatus.equals("2")){%>
								<option value="2" selected>T</option>
							<%}else{%>
								<option value="2">T</option>
							
							<%}if(strStatus.equals("3")){%>
								<option value="3" selected>P</option>
							<%}else{%>
								<option value="3">P</option>
							<%}%>
							</select>
					  </td>
						<td width="70%"><%=strSubCode%> - <%=strSubName%></td>
						<td width="20%" align="right"><%=strLecUnit%>/<%=strLabUnit%></td>
					</tr>				
				<%}
				if(bolHasEntry){%>
					<tr>
						<td height="25" colspan="2">&nbsp;</td>
						<td class="thinborderTOP" align="right"><font style="font-size:12px"><%=dLecUnit%>/<%=dLabUnit%></font></td>
					</tr>
				<%}%>
				</table></td>
			<td width="5%">&nbsp;</td>
		</tr>
	<%}%>
	</table>
	<input type="hidden" name="max_count" value="<%=iCount%>">
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		  <td width="17%">Comment:</td>
			<td width="80%">
				<textarea name="comment" style="font-size:12px" cols="80" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strComment%></textarea></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="40" align="center" valign="bottom">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
					<font size="1">Click to print.</font>
				<a href="javascript:SaveCredEval();"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save subject credit evaluation.</font>
			<%}else{%>
				Not authorized to save subject credit evaluation.
			<%}%></td>
		</tr>
	</table>
<%}%>
			
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#B8CDD1">
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="print_page">
	<input type="hidden" name="save_cred_eval">
	<input type="hidden" name="search_subjects">
	<input type="hidden" name="is_temp_stud" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>