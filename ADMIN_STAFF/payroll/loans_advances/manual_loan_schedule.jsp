<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,payroll.PRMiscDeduction" %>
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
<title>Set Loan schedule as paid</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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

function ReloadPage()
{
	this.SubmitOnce("form_");
}

function focusID() {
  if(document.form_.my_home.value == "0")
		document.form_.emp_id.focus();
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
		location = "manual_loan_schedule.jsp?emp_id="+document.form_.emp_id.value;	
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

// ajax to updateRow
function updateRow(strSched, strRow) {
	var objCOAInput = document.getElementById("coa_info");	
	var strPrincipal = eval('document.form_.principal_amt_'+strRow+'.value');
	var strInterest = eval('document.form_.interest_amt_'+strRow+'.value');
	setEIP(false);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=311&new_principal="+strPrincipal+
							 "&new_interest="+strInterest+"&sched_index="+strSched;

	this.processRequest(strURL);
	//setEIP(true);
}

function deleteRow(strRowIndex, strLabelID) {
		if(!confirm("Continue with delete?"))
			return;
		
		var objCOAInput = document.getElementById(strLabelID);
		setEIP(false);
		this.InitXmlHttpObject(objCOAInput, 2);
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=312&&sched_index="+strRowIndex;
			
		this.processRequest(strURL);
		//setEIP(true);		
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
	String strEmpID = null;
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
	boolean bolIsGovernment = false;
	boolean bolHasPeraa = false;

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
								"Admin/staff-Payroll-LOANS-Set Schedule as Paid","manual_loan_schedule.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();								
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");				
		bolHasPeraa = (readPropFile.getImageFileExtn("HAS_PERAA","0")).equals("1");								
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
	Vector vPersonalDetails = null;
	Vector vRetResult = null;
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	PRMiscDeduction prd = new PRMiscDeduction(request);

	String strLoanType = WI.fillTextValue("loan_type");
	String strCodeIndex = null;	
	String strTypeName = null;
	String strLoanName = null;
	String strPrepareToEdit = "0";
	String strSalDateFr = null;
	double dPrincipal = 0d;
	double dInterest = 0d;
	double dActualPr = 0d;
	double dActualIn = 0d;
	int iSearchResult = 0;
	double dTemp = 0d;
	double dTemp2 = 0d;
	double dDiscrepancyPr = 0d;
	double dDiscrepancyIn = 0d;
	String strRetLoanIndex = null;
	
	String strReadOnly = "";
	String strSchedBase = null;
	Vector vEmpList = null;
	Vector vTemp = null;
	int iCount = 0;
	int i = 0;
	String[] astrTermUnit = {"Months","Years"};
	String strEmpIndex = null;
	double dOldPrincipal = 0d;
	double dOldInterest = 0d;
	double dNewPrincipal = 0d;
	double dNewInterest = 0d;
	boolean bolHasPayment = false;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";	
		
	String[] astrLoanType = {"","","Internal","SSS","Pag-Ibig","PERAA","GSIS"};
	if(strSchCode.startsWith("AUF"))
		astrLoanType[5] = "PSBank";
	
	payroll.PRConfidential prCon = new payroll.PRConfidential();
	boolean bolCheckAllowed = true;
	
	if(!strSchCode.toUpperCase().startsWith("FADI"))
		bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);

	if (WI.fillTextValue("emp_id").length() > 0) {
		if(bolCheckAllowed){	
			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
			if (vPersonalDetails == null || vPersonalDetails.size()==0){
				strErrMsg = authentication.getErrMsg();
				vPersonalDetails = null;
			}
			strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
			
			if(WI.fillTextValue("savelist").length() > 0){
				if(PRRetLoan.operateOnLoanSchedule(dbOP,1) == null)
					strErrMsg = PRRetLoan.getErrMsg();
			}
			
			if(WI.fillTextValue("ret_loan_index").length() > 0){
				//strLoanName = dbOP.mapOneToOther("ret_loan_code","code_index",WI.fillTextValue("code_index"),
				//								 "'(' + loan_code,loan_name + ')' ","");
				vRetResult = PRRetLoan.manualUpdateLoanSchedule(dbOP, request, 4);
				if(vRetResult != null){
					iSearchResult = PRRetLoan.getSearchCount();
					//vTemp = (Vector) vRetResult.elementAt(0);
				}
			}
		}else
			 strErrMsg = prCon.getErrMsg();			
		vEmpList = prd.getEmployeesList(dbOP);
	}
%>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form name="form_" method="post" action="manual_loan_schedule.jsp">
  <%
	if(strLoanType.equals("2")){
		strTypeName = "INTERNAL";
	}else if(strLoanType.equals("3")){
		strTypeName = "SSS";
	}else if(strLoanType.equals("4")){
		strTypeName = "PAG-IBIG";
	}else if(strLoanType.equals("5")){
 		if(strSchCode.startsWith("AUF"))
			strTypeName = "PSBank";
		else
			strTypeName = "PERAA";
	}else if(strLoanType.equals("6")){
		strTypeName = "GSIS";		
	}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
      PAYROLL : LOAN SCHEDULE PAYMENTS PAGE ::::</strong></font></td>
    </tr>
	<%if(!bolMyHome){%>
    <tr bgcolor="#FFFFFF">
      <td width="50%" height="25">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
      <td width="50%" align="right"><%
	  		if (vEmpList != null && vEmpList.size() > 0){
			  %>
        <%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
        <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
        <%}else{%>
FIRST
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
<%}else{%>
PREVIOUS
<%}%>
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
<%}else{%>
NEXT
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=((String)vEmpList.elementAt(vEmpList.size()-1)).toUpperCase()%>');">LAST</a>
<%}else{%>
LAST
<%}%>
<%}// if (vEmpList != null && vEmpList.size() > 0)%></td>
    </tr>
	<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%if(!bolMyHome){%>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="21%" height="27">Employee ID :</td>
      <td width="76%" height="27"> <font size="1">
        <input name="emp_id" type="text" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">
        <strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong>
        <input type="submit" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #999999;">
        </font><label id="coa_info"></label></td>
    </tr>
	<%}else{%>
		<input type="hidden" name="emp_id" value="<%=strEmpID%>">
	<%}%>
  </table>
    <% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">&nbsp;Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="30">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%>
        /Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>&nbsp;Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="97%">&nbsp;Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>
    </tr>
    <tr>
      <td height="19" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<!--		
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="18%" height="26">&nbsp;Loan Code :</td>
	  <%//strCodeIndex = WI.fillTextValue("code_index");%>
      <td height="26" colspan="3"><font size="1"><strong>
        <select name="code_index" onChange="ReloadPage();">
          <option value="">Select Loan</option>
          <%//=dbOP.loadCombo("code_index","loan_code,loan_name ",
		         //           " from ret_loan_code where is_valid = 1 and loan_type > 1" +
							//					" and exists(select * from retirement_loan where user_index = " + strEmpIndex +
							//					" and retirement_loan.code_index = ret_loan_code.code_index and is_finished = 0)" , strCodeIndex ,false)%>
        </select>
      </strong></font></td>
    </tr>
		-->
    <tr>
      <td>&nbsp;</td>
      <td height="26">Loan Type</td>
			<%
				strLoanType = WI.fillTextValue("loan_type");
			%>
      <td height="26" colspan="3"><font size="1"><strong>
        <select name="loan_type" onChange="ReloadPage();">
          <option value="">Select Loan</option>
					<%for(i= 2; i < astrLoanType.length;i++){
						
						if(!bolIsGovernment && i == 6)
							continue;
						
						if(!bolHasPeraa && i == 5)
							continue;
							
					
						if(strLoanType.equals(Integer.toString(i))){
					%>
						<option value="<%=i%>" selected><%=astrLoanType[i]%></option>
					<%}else{%>
						<option value="<%=i%>"><%=astrLoanType[i]%></option>
					<%}
					}%>
        </select>
      </strong></font></td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="18%" height="26">&nbsp;Loan Code</td>
	  <%strRetLoanIndex = WI.fillTextValue("ret_loan_index");
	  			if(strLoanType != null && strLoanType.length() > 0)
					strTemp = " and loan_type = " + strLoanType;
				else
					strTemp = "";	
	  
	  %>
      <td height="26" colspan="3"><font size="1"><strong>
        <select name="ret_loan_index" onChange="ReloadPage();">
          <option value="">Select Loan</option>
          <%=dbOP.loadCombo("ret_loan_index","loan_name, amount", 
												" from ret_loan_code " +
												" join retirement_loan on (retirement_loan.code_index = ret_loan_code.code_index) " +
												//" where retirement_loan.is_valid = 1 and loan_type = " + strLoanType +
												" where retirement_loan.is_valid = 1 " + strTemp +
												" and user_index = " + strEmpIndex + 
												" and is_finished = 0 " + 
												" and exists(select * from ret_loan_schedule " +
												"    where ret_loan_schedule.ret_loan_index = retirement_loan.ret_loan_index) " +
												" order by is_finished asc", strRetLoanIndex ,false)%>
        </select>
      </strong></font>			  </td>
    </tr>		
    <tr>
      <td height="17" colspan="5"><hr size="1"></td>
    </tr>
	<%if(vTemp != null && vTemp.size() > 0){
		strLoanName = (String)vTemp.elementAt(6);
	%>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Amount Loaned</td>
      <td width="36%">&nbsp;<%=(String)vTemp.elementAt(0)%></td>
      <td width="15%" height="27">&nbsp;Terms<strong><font size="1"> </font></strong></td>
      <td width="28%">&nbsp;<%=(String)vTemp.elementAt(1)%> <%=astrTermUnit[Integer.parseInt(WI.getStrValue((String)vTemp.elementAt(4),"0"))]%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Release Date</td>
      <td>&nbsp;<%=WI.getStrValue((String)vTemp.elementAt(2),"")%></td>
      <td height="27">&nbsp;First Payment</td>
      <td>&nbsp;<%=(String)vTemp.elementAt(3)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Payable Balance</td>
			<%
				strTemp = (String)vTemp.elementAt(5);
			%>
      <td>&nbsp;<%=strTemp%><input type="hidden" name="payable_bal" value="<%=strTemp%>">			</td>
      <td height="27">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">Last updated by</td>
			<%
				strTemp = (String)vTemp.elementAt(8);
			%>			
      <td height="27" colspan="3">&nbsp;<%=WI.getStrValue(strTemp)%></td>
    </tr>
	<%}%>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
   <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
     <tr>
       <td>&nbsp; </td>
     </tr>
   </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF"> 
      <td height="25" colspan="6" align="center" class="BorderAll"><strong>:: 
        AMORTIZATION SCHEDULE FOR <%=strTypeName%> LOAN ::</strong></td>
    </tr>
    <tr> 
      <td width="13%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">DATE</font></strong></td>
      <td width="16%" align="center" class="BorderBottomLeft"><strong><font size="1">PAID PRINCIPAL</font></strong></td>
      <td width="15%" align="center" class="BorderBottomLeft"><strong><font size="1">PAID INTEREST</font></strong></td>
      <td width="22%" align="center" class="BorderBottomLeft"><strong><font size="1"> PRINCIPAL</font></strong></td>
      <td width="20%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1"> INTEREST</font></strong></td>
      <!--
	  <td width="22%" height="24" class="BorderBottomLeft"><div align="center"><strong><font size="1">PRINCIPAL</font></strong></div></td>	  
      <td width="27%" class="BorderBottomLeft"><div align="center"><strong><font size="1">INTEREST</font></strong></div></td>
	  -->
      <td width="14%" align="center" class="BorderBottomLeftRight">
		   <strong><font size="1">OPTION</font></strong>	     </td>
    </tr>
    <%for(i = 0; i < vRetResult.size() ; i+=8,iCount++){
			bolHasPayment = false;
		%>
    <tr> 
			<input type="hidden" name="schedule_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0)
					bolHasPayment = true;
				dOldPrincipal += dTemp;
			%>
      <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+7));
				dTemp = Double.parseDouble(strTemp);
				if(dTemp > 0)
					bolHasPayment = true;
									
				dOldInterest += dTemp;
			%>			
      <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
			<%
				strTemp2 = WI.fillTextValue("principal_amt_"+iCount);
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
				if(strTemp2.length() == 0)
					strTemp2 = strTemp;
				dTemp = Double.parseDouble(strTemp);
				dNewPrincipal += dTemp;				
				
			%>
      <td align="right" class="BorderBottomLeft"><strong>
			<%=strTemp%>
			<%if(!bolHasPayment){%>
        <input name="principal_amt_<%=iCount%>" type="text" class="textbox" size="7" maxlength="10" 
				onfocus="style.backgroundColor='#D3EBFF'"
				onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				onblur="AllowOnlyFloat('form_','principal_amt_<%=iCount%>');style.backgroundColor='white'" 
				onKeyUp="AllowOnlyFloat('form_','principal_amt_<%=iCount%>');"
				value="<%=strTemp2%>" style="text-align:right;font-size:11px;">
				<%}%>
      </strong>&nbsp;</td>
			<%
				strTemp2 = WI.fillTextValue("interest_amt_"+iCount);
				
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4), true);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
				
				if(strTemp2.length() == 0)
					strTemp2 = strTemp;
					
				dTemp = Double.parseDouble(strTemp);
				dNewInterest += dTemp;
			%>
      <td height="29" align="right" class="BorderBottomLeft"><%=strTemp%>
			<%if(!bolHasPayment){%>
				<input name="interest_amt_<%=iCount%>" type="text" class="textbox" size="7" maxlength="10" 
				onfocus="style.backgroundColor='#D3EBFF'"
				onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				onblur="AllowOnlyFloat('form_','interest_amt_<%=iCount%>');style.backgroundColor='white'" 
				onKeyUp="AllowOnlyFloat('form_','interest_amt_<%=iCount%>');"
				value="<%=strTemp2%>" style="text-align:right">
				<%}%>&nbsp;</td>
      <!--
	  <td height="29" class="BorderBottomLeft"><div align="right"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</div></td>	  
      <td class="BorderBottomLeft"><div align="right"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</div></td>
	  -->
      <td align="center" nowrap class="BorderBottomLeftRight">&nbsp;
			<%if(!bolHasPayment){%>
			<a href="javascript:updateRow('<%=WI.fillTextValue("schedule_"+iCount)%>', '<%=iCount%>');">UPDATE</a>&nbsp;
			<label id="delete_<%=iCount%>">
			<a href="javascript:deleteRow('<%=WI.fillTextValue("schedule_"+iCount)%>', 'delete_<%=iCount%>');">DELETE</a>
			</label>
			<%}%>
			&nbsp;
			</td>
    </tr>
    <%}%>
		<input type="hidden" name="recordcount" value="<%=iCount%>">
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td>TOTALS :</td>
      <td align="right"><%=CommonUtil.formatFloat(dOldPrincipal, true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dOldInterest, true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dNewPrincipal, true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dNewInterest, true)%>&nbsp;</td>
      <td height="24">&nbsp;</td>
    </tr>
    <tr>
 
      <td height="24" colspan="6">&nbsp;</td>
    </tr>
    <tr>
      <td height="24" colspan="6"><font size="2" color="#FF0000"><strong>WARNING!</strong></font>
			  <br>
		  Updating loan schedule from this page will also affect the actual payable balance and the actual schedule of the loan</td>
    </tr>
  </table>
  <%} // end if vRetResult != null %>
  <%}// largest if... (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="savelist">	
  <input type="hidden" name="loan_type" value="<%=WI.fillTextValue("loan_type")%>">
  <input type="hidden" name="loan_name" value="<%=strLoanName%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();

%>
