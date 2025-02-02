<%@ page language="java" import="utility.*,java.util.Vector,hr.HRLighthouse" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Evaluations Summary</title>
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

function ReloadPage(){
	document.form_.searchEmployee.value = "1";
	document.form_.submit();
}

function RefreshPage() {
	document.form_.searchEmployee.value="";
	document.form_.submit();
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.submit();
}

function UpdateEmployeePerformanceEvaluation(strPerfEvalMainIndex, strRPIndex, strEmpEvaluated){
	var sT = "./update_perf_eval.jsp?opner_form_name=form_&read_only=0&perf_eval_main_index="+strPerfEvalMainIndex+"&rp_index="+strRPIndex+"&emp_evaluated="+strEmpEvaluated;
	var win=window.open(sT,"UpdateEmployeePerformanceEvaluation",'dependent=yes,width=800,height=700,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewEmployeeSelfEvaluation(strSelfEvalMainIndex){
	var sT = "./update_self_eval.jsp?read_only=1&self_eval_main_index="+strSelfEvalMainIndex;
	var win=window.open(sT,"ViewEmployeeSelfEvaluation",'dependent=yes,width=700,height=700,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UnfinalizeSelfEval(strSEMI){
	document.form_.unfinalize_self_eval.value = strSEMI;
	this.SearchEmployee();
}

var objCOA;
var objCOAInput;

function AjaxMapName(strFieldName, strLabelID) {
	objCOA=document.getElementById(strLabelID);
	var strCompleteName = eval("document.form_."+strFieldName+".value");
	eval('objCOAInput=document.form_.'+strFieldName);
	if(strCompleteName.length <= 2) {
		objCOA.innerHTML = "";
		return ;
	}		
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
	"&name_format=4&complete_name="+escape(strCompleteName);
	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	objCOAInput.value = strID;
	objCOA.innerHTML = "";
	//document.dtr_op.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
}

function PopUpReport(strPEMI){
	var loadPg = "./evaluations_final_report.jsp?perf_eval_main_index="+strPEMI;
	var win=window.open(loadPg,"PopUpReport",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-CLEARANCE"),"0"));
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
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Clearance-Post Clearances","evaluations_summary.jsp");
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

	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	int iSearchResult = 0;
	
	HRLighthouse hrl = new HRLighthouse();	

	if(WI.fillTextValue("unfinalize_self_eval").length() > 0){
		if(!hrl.unfinalizeSelfEval(dbOP, request, WI.fillTextValue("unfinalize_self_eval")))
			strErrMsg = hrl.getErrMsg();
	}

	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
		
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	    vRetResult = hrl.searchEmployeePerformance(dbOP,request);
		if(vRetResult == null)
			strErrMsg = hrl.getErrMsg();
		else
			iSearchResult = hrl.getSearchCount();
	}	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="evaluations_summary.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: EVALUATIONS SUMMARY ::::</strong></font></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr> 
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Review Title </td>
		    <td colspan="3" height="25">
				<select name="rp_index">
					<option value="">Select Review Title</option>
					<%=dbOP.loadCombo("rp_index","rp_title"," from hr_lhs_review_period "+
						"where is_valid = 1 order by period_open_fr",WI.fillTextValue("rp_index"),false)%>
				</select></td>
		</tr>
		<tr>
			<td height="24">&nbsp;</td>
			<td>Status</td>
			<td colspan="3">
				<select name="pt_ft" onChange="RefreshPage();">
				<option value="">All</option>
				<%if (WI.fillTextValue("pt_ft").equals("0")){%>
					<option value="0" selected>Part-time</option>
				<%}else{%>
					<option value="0">Part-time</option>
					
				<%}if (WI.fillTextValue("pt_ft").equals("1")){%>
					<option value="1" selected>Full-time</option>
				<%}else{%>
					<option value="1">Full-time</option>
				<%}%>
				</select></td>
		</tr>
		<%if(bolIsSchool){%>
		<tr>
			<td height="24">&nbsp;</td>
			<td>Employee Category</td>
			<td colspan="3">
				<select name="employee_category" onChange="RefreshPage();">          
				<option value="">All</option>
				<%if (WI.fillTextValue("employee_category").equals("0")){%>
					<option value="0" selected>Non-Teaching</option>
				<%}else{%>
					<option value="0">Non-Teaching</option>				
				<%}if (WI.fillTextValue("employee_category").equals("1")){%>
					<option value="1" selected>Teaching</option>
				<%}else{%>
					<option value="1">Teaching</option>
				<%}%>
				</select></td>
		</tr>
		<%}%>
		<% 	
			String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
		<tr> 
			<td height="24">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
			<td colspan="3">
				<select name="c_index" onChange="RefreshPage();">
					<option value="">N/A</option>
					<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
				</select>			</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>Department/Office</td>
			<td colspan="3">
				<select name="d_index" onChange="RefreshPage();">
					<option value="">ALL</option>
					<%if (strCollegeIndex.length() == 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
					<%}else if (strCollegeIndex.length() > 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
					<%}%>
				</select>			</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>Employee ID </td>
			<td width="25%">
				<input name="user_index" type="text" size="16" value="<%=WI.fillTextValue("user_index")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('user_index','user_index_');">
					<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>				</td>
		    <td width="52%"><label id="user_index_"></label></td>
		</tr>
		<tr> 
			<td height="10" colspan="5"><hr size="1" color="#000000"></td>
		</tr>
		<tr>
			<td height="10" colspan="5">OPTION:</td>
		</tr>
		<tr> 
			<td height="10">&nbsp;</td>
		  <td colspan="4">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("with_self_eval"),"1");
	if(strTemp.equals("1")) {
		strTemp = " checked";
		strErrMsg = "";
	}
	else {
		strTemp = "";	
		strErrMsg = " checked";
	}
%>
    <input type="radio" name="with_self_eval" value="1"<%=strTemp%> onClick="RefreshPage();"> 
    View Employees With Self Evaluation
	<input type="radio" name="with_self_eval" value="0"<%=strErrMsg%> onClick="RefreshPage();"> 
	View Employees w/out Self Evaluation </td>
	</tr>
	<tr>
		<td height="10">&nbsp;</td>
		<td colspan="4">
		<%
			if(WI.fillTextValue("view_all").length() > 0)
				strTemp = " checked";				
			else
				strTemp = "";
		%>
		<input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="RefreshPage();"> 
		View ALL </td>
	</tr>
</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr> 
      		<td width="3%" height="29">&nbsp;</td>
      		<td>SORT BY :</td>
      		<td height="29">
				<select name="sort_by1">
        			<option value="">N/A</option>
					<%=hrl.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      			</select>			</td>
      		<td height="29">
				<select name="sort_by2">
        			<option value="">N/A</option>
					<%=hrl.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
				</select>			</td>
	      	<td height="29">
				<select name="sort_by3">
        			<option value="">N/A</option>        
					<%=hrl.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      			</select></td>
    	</tr>
    	<tr> 
      		<td height="15">&nbsp;</td>
      		<td width="11%" height="15">&nbsp;</td>
      		<td>
				<select name="sort_by1_con">
       				<option value="asc">Ascending</option>
        			<%
						if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        					<option value="desc" selected>Descending</option>
        				<%}else{%>
        					<option value="desc">Descending</option>
        				<%}%>
      			</select>			</td>
      		<td>
				<select name="sort_by2_con">
        			<option value="asc">Ascending</option>
        			<%
						if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
							<option value="desc" selected>Descending</option>
						<%}else{%>
							<option value="desc">Descending</option>
						<%}%>
				</select></td>
			<td>
				<select name="sort_by3_con">
					<option value="asc">Ascending</option>
					<%
						if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
							<option value="desc" selected>Descending</option>
						<%}else{%>
							<option value="desc">Descending</option>
						<%}%>
				</select></td>
    	</tr>
		<tr>
			<td height="10" colspan="5">&nbsp;</td>
		</tr>
		<tr> 
			<td height="10" colspan="2">&nbsp;</td>
	  	  <td height="10" colspan="3">
				<input type="button" name="proceed_btn" value=" Proceed " onClick="javascript:SearchEmployee();"
					style="font-size:11px; height:28px;border: 1px solid #FF0000;" >
			<font size="1">click to display employee list to display.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
  	</table>    

<%if(vRetResult != null &&  vRetResult.size() > 0) {%>	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<%
				strTemp = "LIST OF EMPLOYEES";
				if((WI.fillTextValue("with_self_eval")).equals("1"))
					strTemp += " WITH SELF EVALUATION ";
				else
					strTemp += " WITHOUT SELF EVALUATION ";
			%>
		  	<td height="20" colspan="2" bgcolor="#B9B292" class="thinborder">				
				<div align="center"><strong>::: <%=strTemp%> :::</strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" height="25" width="60%">
				<strong>Total Results: <%=iSearchResult%> - 
					Showing(<strong><%=WI.getStrValue(hrl.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" width="40%">&nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/hrl.defSearchSize;		
				if(iSearchResult % hrl.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+hrl.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="SearchEmployee();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}}%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    	<tr>
			<td height="25" width="5%" align="center" class="thinborder">Count</td>
			<td width="10%" align="center" class="thinborder">Employee ID</td> 
			<td width="23%" align="center" class="thinborder">Employee Name</td>
			<td width="30%" align="center" class="thinborder">Department/Office</td>
		<%if((WI.fillTextValue("with_self_eval")).equals("1")){%>
			<td width="8%" align="center" class="thinborder">Self<br>Eval</td>
			<td width="10%" align="center" class="thinborder">Perf<br>Eval</td>
			<td width="7%"  align="center" class="thinborder">Status</td>
			<td width="7%"  align="center" class="thinborder">Unfinalize</td>
		<%}%>
    	</tr>
    	<% 
			int iCount = 1;
	   		for (i = 0; i < vRetResult.size(); i+=13,iCount++){
		%>
    	<tr>
      		<td align="center" class="thinborder"><%=iCount%></td>
      		<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td> 
      		<td height="25" class="thinborder">&nbsp;
				<font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),
					(String)vRetResult.elementAt(i+6), 4).toUpperCase()%></strong></font></td>
      		<td class="thinborder">&nbsp;
				<%
					if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null)
						strTemp = " ";
					else
						strTemp = " - ";
				%>
	   			<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"")%></td>
		<%if((WI.fillTextValue("with_self_eval")).equals("1")){%>
   		    <td align="center" class="thinborder">
				<a href="javascript:ViewEmployeeSelfEvaluation('<%=(String)vRetResult.elementAt(i+1)%>');">
					<img src="../../../images/view.gif" border="0"></a></td>			
	      	<td align="center" class="thinborder">
				<%
				//if performance is not reviewed and the user who logged in is the immediate supervisor, then allow edit
				strTemp = (String)vRetResult.elementAt(i+9);//is_reviewed.. 0-not yet reviewed, 1-already reviewed
				strErrMsg = (String)vRetResult.elementAt(i+10);
				
				//if not reviewd, and logged in user is the immediate supervisor
				if(strTemp.equals("0") && strErrMsg != null && strUserIndex.equals(strErrMsg)){%>
					<a href="javascript:UpdateEmployeePerformanceEvaluation('<%=(String)vRetResult.elementAt(i+2)%>', '<%=(String)vRetResult.elementAt(i)%>', '<%=(String)vRetResult.elementAt(i+11)%>');">
						<img src="../../../images/update.gif" border="0"></a>
				<%}else if((String)vRetResult.elementAt(i+12) == null || Integer.parseInt((String)vRetResult.elementAt(i+12)) == 0){%>
					N/A
				<%}else{%>
					<a href="javascript:PopUpReport('<%=(String)vRetResult.elementAt(i+2)%>')">
						<img src="../../../images/view.gif" border="0"></a>
				<%}%></td>
			<td align="center" class="thinborder">
				<%
					if(strTemp.equals("0"))
						strTemp = "Pending";
					else
						strTemp = "Reviewed";
				%>
				<%=strTemp%></td>
			<td align="center" class="thinborder">
				<%if(strTemp.equals("Reviewed")){%>
					<a href="javascript:UnfinalizeSelfEval('<%=(String)vRetResult.elementAt(i+1)%>')"><strong>UNFINALIZE</strong></a>
				<%}else{%>
					N/A
				<%}%></td>
		<%}%>
    	</tr>
    	<%} //end for loop%>
	</table>
	<% } // end vRetResult != null && vRetResult.size() > 0 %>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="searchEmployee" > 
	<input type="hidden" name="page_action">	
	<input type="hidden" name="clearance_name">
	<input type="hidden" name="unfinalize_self_eval">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>