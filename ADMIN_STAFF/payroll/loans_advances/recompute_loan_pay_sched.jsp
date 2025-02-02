<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Reset Loan Schedule</title>
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

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage() {	
	document.form_.viewRecords.value="";
	document.form_.recompute.value="";
	document.form_.submit();
}

function ViewEmployees() {	
	document.form_.viewRecords.value="1";
	document.form_.recompute.value="";
	document.form_.submit();
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}



function Recompute() {
	var lblLoading = document.getElementById("loading_");
	document.form_.viewRecords.value="1";
	document.form_.recompute.value="1";
	document.form_.compute_btn.style.visibility = "hidden";
 	lblLoading.innerHTML = '<img src="../../../Ajax/ajax-loader_small_black.gif">processing...';
	document.form_.submit();
}

function SaveList(){
	document.form_.savelist.value="1";
	document.form_.save_btn.disabled = true;
	this.SubmitOnce("form_");
}

function CopyID(strID)
{
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");
}
function CancelRecord(){
		location = "loan_pay_sched.jsp?emp_id="+document.form_.emp_id.value;	
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolMyHome = false;
	boolean bolHasTeam = false;	
	String strEmpID = null;	
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
 
 	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));		
		
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
		
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES-SETASPAID"),"0"));
	}
	
	strEmpID = (String)request.getSession(false).getAttribute("userId");
	if (strEmpID != null ){
		if(bolMyHome){
			iAccessLevel  = 2;
			request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
		}
	}

	strEmpID = WI.fillTextValue("emp_id");
	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");

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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS-Set Schedule as Paid","loan_pay_sched.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");						
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

	//end of authenticaion code.
	
	//////////////////// start of operation \\\\\\\\\\\\\\\\\\\\\\|
	Vector vRetResult = null;
	PRRetirementLoan  prRetLoan =  new PRRetirementLoan(request);
	int iSearchResult = 0;
	
	if (WI.fillTextValue("recompute").equals("1")) { 
		if (prRetLoan.operateRecomputeLoanSchedule(dbOP, request, 1) == null) 
			strErrMsg = prRetLoan.getErrMsg();
		else
			strErrMsg  = "Operation Successful";
	}
	
	if (WI.fillTextValue("viewRecords").equals("1")) { 
		prRetLoan.defSearchSize = 10; //10 results per operation so that tomcat wont be stressed
		vRetResult = prRetLoan.operateRecomputeLoanSchedule(dbOP,request, 4);
		if(vRetResult == null)
			strErrMsg = prRetLoan.getErrMsg();
		else
			iSearchResult = prRetLoan.getSearchCount(); 
	}	
	
	
%>
	
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="recompute_loan_pay_sched.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
      PAYROLL : RECOMPUTE LOAN SCHEDULE PAYMENTS PAGE ::::</strong></font></td>
    </tr>
	<tr bgcolor="#FFFFFF"> 
      <td height="25" ><strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong>
        <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
          <tr height="10">
            <td height="38">&nbsp;</td>
          </tr>
          <tr>
            <td width="142">&nbsp;</td>
            <td width="125">Select Loan Type</td>
            <td width="715"><%String strRetLoanIndex = WI.fillTextValue("CODE_INDEX");%>
                <font size="1"> <strong>
                <select name="CODE_INDEX" onChange="ReloadPage();">
                  <option value="">Select Loan</option>
                  <%=dbOP.loadCombo("CODE_INDEX","LOAN_CODE , LOAN_NAME", 
												" from ret_loan_code " +												
												" where loan_type > 1 AND IS_VALID = 1 AND IS_DEL = 0"												
												,strRetLoanIndex ,false)%>
                </select>
              </strong></font> </td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <% 	
		String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
            <td><%if(bolIsSchool){%>
              College
              <%}else{%>
              Division
              <%}%></td>
            <td><select name="c_index" onChange="ReloadPage();">
                <option value="">N/A</option>
                <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
              </select>            </td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td>Department/Office</td>
            <td><select name="d_index" onChange="ReloadPage();">
                <option value="">ALL</option>
                <%if (strCollegeIndex.length() == 0){%>
                <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%>
                <%}else if (strCollegeIndex.length() > 0){%>
                <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%>
                <%}%>
              </select>            </td>
          </tr>
          <!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Office/Dept filter </td>
      <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
	-->
          <tr>
            <td height="25">&nbsp;</td>
            <td>Employee Type </td>
            <%
				strTemp = WI.fillTextValue("emp_type_index");			
			%>
            <td><select name="emp_type_index">
                <option value="">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
 				"order by EMP_TYPE_NAME asc", strTemp, false)%>
              </select>            </td>
          </tr>
         
		 <%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>
      </td>
    </tr>
		<%}%>
	
          <tr height="10">
            <td height="18">&nbsp;</td>
            <td height="18">&nbsp;</td>
            <td height="25" colspan="2"><%if (WI.fillTextValue("view_all").equals("1")) 
			strTemp = "checked";
			else
				strTemp = "";
		%>
		<div style="display:none">
                <input type="checkbox" name="view_all" value="1" <%=strTemp%> >
                <!-- dispaly:none so that user wont be able to have batch recompute -->
                <font size="1"> show all</font></td>
		</div>		
          </tr>
          <tr>
            <td height="10">&nbsp;</td>
            <td height="10" colspan="3"><input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewEmployees();">
                <font size="1">click to proceed</font></td>
          </tr>
          <tr height="10">
            <td height="38">&nbsp;</td>
      </table></td>
    </tr>
  </table> 
   <%if(vRetResult != null && vRetResult.size() > 0){%>
   		<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">    
			<%if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = iSearchResult/prRetLoan.defSearchSize;		
				if(iSearchResult % prRetLoan.defSearchSize > 0) ++iPageCount;
				if(iPageCount > 1){%>
					<tr>
		  				<td>
							<div align="right"><font size="2">Jump To page:
							<select name="jumpto" onChange="ViewRecords();">
							 <%
								strTemp = request.getParameter("jumpto");
								if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
					
								for(int i =1; i<= iPageCount; ++i ){
									if(i == Integer.parseInt(strTemp) ){%>
									  <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
									  <%}else{%>
									  <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
									  <%
									 }
								}
				%>
			  </select>
		  </font></div></td>
		</tr>
		<%} // end if pages > 1
			}// end if not view all%>
	  </table>   
	  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  <td height="20" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
		</tr>
		
		<tr>
		  <td width="10%" align="center" class="thinborder"><strong><font size="1">COUNT</font></strong></td>
		  <td width="18%" align="center" class="thinborder"><strong><font size="1">ID NUMBER</font></strong></td>
		  <td width="23%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
		  <td width="37%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
		  <td width="12%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
			</strong>
			<input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
		  </font></td>
		</tr> 
		<%
		int iCount = 1;
		for (int i = 0; i < vRetResult.size(); i+=9,iCount++){ %>
			 <tr>
			  	<input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">			
				<input type="hidden" name="com_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+8)%>">
				<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;&nbsp;<%=iCount%></span></td>
			    <td class="thinborder">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
			    <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
									(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
					
				<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
			 	<%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
					strTemp = " ";			
				  }else{
					strTemp = " - ";
				  }			
				%>
			  <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%></td>
			  <td align="center" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1">      </td>
			</tr>
		
		
		<%}//end of for loop
		%>		
		
		<input type="hidden" name="emp_count" value="<%=iCount%>">
	  </table>	  	  
	  	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>&nbsp;</td>
				<%
					strTemp = WI.fillTextValue("use_4");
					if(strTemp.equals("1"))
						strTemp = " checked";
					else
						strTemp = "";
				%>				
			  	<td height="27"><input type="checkbox" name="use_4" value="1" <%=strTemp%>>
				if weekly employees, deduct only on first four(4) schedules of the month </td>
			
			</tr>
			<tr>
				<td>&nbsp;</td>
			  	<td height="25"  bgcolor="#FFFFFF">
					<%if(iAccessLevel == 2){%>
					<input type="button" name="compute_btn" value=" Recompute " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:Recompute();"><label id="loading_" style="position:fixed"></label>
					<%}else{%>
						Not Allowed to Reset loan schedule
					<%}%>					
				</td>
			</tr>
		 </table>
	  
	  
  <%}//end of vRetResult ! null %>
  
  
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#FFFFFF">
      <td height="25" colspan="2" align="center">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic">&nbsp;</td>
    </tr>
</table> 
  
<input type="hidden" name="viewRecords">
<input type="hidden" name="page_action">
<input type="hidden" name="recompute">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
