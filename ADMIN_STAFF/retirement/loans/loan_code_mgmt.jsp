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
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function PageAction(strPageAction, strInfoIndex,strCode){	
	document.form_.print_page.value = "";
	if (strPageAction == 0){
		var vProceed = confirm('Delete '+strCode+' ?');
		if(vProceed){
			document.form_.page_action.value = strPageAction;
			document.form_.info_index.value = strInfoIndex;
			document.form_.prepareToEdit.value = "";
			this.SubmitOnce('form_');
		}		
	}
	else{	
	document.form_.page_action.value = strPageAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce("form_");
	}
}

function PrepareToEdit(strInfoIndex){	
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function ReloadPage()
{
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function GenerateLoanCode(){
	var vCode = "";
	if (document.form_.sy_to.value.length == 0 || document.form_.sy_from.value.length == 0)
	  return;
	else{
	  if (document.form_.loan_type.value == 0)
		vCode = "R";
	  else
	  	vCode = "E";
	  
	  if (document.form_.semester.value == 1)
	    vCode += document.form_.sy_from.value + "A";
	  else
	    vCode += document.form_.sy_from.value + "B";
	document.form_.loan_code.value = vCode;
	}		
}

-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./loan_code_mgmt_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT-LOANS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT"),"0"));
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-RETIREMENT-LOANS-Create Loans","loan_code_mgmt.jsp");
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
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);

	String strDay = null;		
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strPageAction = WI.fillTextValue("page_action");
	String strLoanType = null;
	String strInfoIndex = WI.fillTextValue("info_index");
	String[] astrLoanType = {"Regular Retirement Loan","Emergency Retirement Loan"};
	String[] astrSemester = {"","1st sem","2nd sem"};
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};
	String[] astrUnit = {"%",""};
	String[] astrFrequency = {"per annum","per month","per day"};
	
	if (strPageAction.length() > 0){
		if (strPageAction.compareTo("0")==0) {
			if (PRRetLoan.operateOnLoanCode(dbOP,request,0) != null){
				strErrMsg = "Loan code deleted successfully";
			}else{
				strErrMsg = PRRetLoan.getErrMsg();
			}
		}else if(strPageAction.compareTo("1") == 0){
			if (PRRetLoan.operateOnLoanCode(dbOP,request,1) != null){
				strErrMsg = " Loan code saved successfully";
			}else{
				strErrMsg = PRRetLoan.getErrMsg();
			}
		}else if(strPageAction.compareTo("2") == 0){
			if (PRRetLoan.operateOnLoanCode(dbOP,request,2) != null){
				strErrMsg = " Loan code updated successfully";
				strPrepareToEdit = "";
			}else{
				strErrMsg = PRRetLoan.getErrMsg();
			}
		}
	}
	
	if (strPrepareToEdit.length() > 0){
		vEditInfo = PRRetLoan.operateOnLoanCode(dbOP,request,3);
		if (vEditInfo == null)
			strErrMsg = PRRetLoan.getErrMsg();
	}
	
	vRetResult = PRRetLoan.operateOnLoanCode(dbOP,request,4);
	if (vRetResult != null && strErrMsg == null){
		strErrMsg = PRRetLoan.getErrMsg();	
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./loan_code_mgmt.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::RETIREMENT 
          - LOANS - LOAN CODE MGMT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="20%" height="27">School Year</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		else
	  		strTemp = WI.fillTextValue("sy_from");
	  %>
      <td width="34%" height="27"><input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	   onKeyUp="DisplaySYTo('form_','sy_from','sy_to');GenerateLoanCode();">
		to 
        <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		else				
		    strTemp = WI.fillTextValue("sy_to");
	  %> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
      <td width="12%">Semester</td>
      <td width="32%" colspan="2">
	  <select name="semester" onChange="GenerateLoanCode();">
          <option value="1">1st Semester</option>
          <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);
		else		  
			strTemp = WI.fillTextValue("semester");
		if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Semester</option>
          <%}else{%>
          <option value="2">2nd Semester</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Loan Type</td>
      <td height="27">
	     <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strLoanType = (String)vEditInfo.elementAt(5);
		else		 
		 	strLoanType = WI.fillTextValue("loan_type");
		 %>
		 <select name="loan_type" onChange="GenerateLoanCode();ReloadPage();">
          <option value="0">Regular Retirement Loan</option>
          <%if(strLoanType.equals("1")){%>
          <option value="1" selected>Emergency Loan</option>
          <%}else{%>
          <option value="1">Emergency Loan</option>
          <%}%>
        </select></td>
      <td height="27">Loan Code :</td>
	   <% 
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		else	   
	   	    strTemp = WI.fillTextValue("loan_code");   
	   %>
      <td height="27" colspan="2"><input name="loan_code" type="text" size="10" maxlength="10" value="<%=strTemp%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Interest :</td>
      <td height="27" colspan="4">
		<%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		else			  
			strTemp = WI.fillTextValue("interest_val");
		%>
	  <input name="interest_val" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        % per annum 
        <!--
		<%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		else			  
			strTemp = WI.fillTextValue("unit");
		%>		
        <select name="unit">
          <option value="0">%</option>
          <%if(strTemp.equals("1")){%>
          <option value="1" selected>amount</option>
          <%}else{%>
          <option value="1">amount</option>
          <%}%>
        </select> 

		<%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);
		else			  
			strTemp = WI.fillTextValue("frequency");
		%>	
		<select name="frequency">
          <option value="0">per annum</option>
          <%if(strTemp.equals("1")){%>
          <option value="1" selected>per month</option>
		  <option value="2">per day</option>
          <%}else if(strTemp.equals("2")){%>
          <option value="1">per month</option>
		  <option value="2" selected>per day</option>
		  <%}else{%>
          <option value="1">per month</option>
		  <option value="2">per day</option>
          <%}%>
        </select>
		-->
      </td>
    </tr>
	<%if(false){%>
    <tr> 
      <td>&nbsp;</td>
      <td height="27"> Date of 1st payment: </td>
      <td height="27" colspan="4"><font size="1"> 
		<%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(9);
		else			  
			strTemp = WI.fillTextValue("month");
		%>
        <select name="month">
		 <option value="<%=0%>"><%=astrConvertMonth[0]%></option>
          <%for(int i = 1; i < 12; ++i){%>
			 <%if(strTemp.equals(Integer.toString(i))){%>
			   <option value="<%=i%>" selected><%=astrConvertMonth[i]%></option>
			 <%}else{%>
			   <option value="<%=i%>"><%=astrConvertMonth[i]%></option>
			 <%}%>
          <%}%>
        </select>
		<%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strDay = (String)vEditInfo.elementAt(10);
		else			  
			strDay = WI.fillTextValue("day");
		%>		
        <select name="day">
          <% for(int i = 1; i < 32; ++i) {
			if(strDay.equals(Integer.toString(i)))
				strTemp = "selected";
			else	
				strTemp = "";
	 	%>
          <option value="<%=i%>" <%=strTemp%>><%=i%></option>
          <%}%>
        </select>
        </font></td>
    </tr>
	<%}// end if(strLoanType.equals("1")) %>
    <tr> 
      <td height="27" colspan="6"><div align="center">
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1, "","");'> <img src="../../../images/save.gif" border="0" id="hide_save"></a><font size="1"> 
          click to save entries</font> 
          <%}else{%>
          <a href="javascript:PageAction(2,'<%=strInfoIndex%>','');"> <img src="../../../images/edit.gif"border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif"> 
          click to save changes</font> 
          <%}%>
          <a href="./loan_code_mgmt.jsp"><img src="../../../images/cancel.gif" border="0"></a> 
          <font size="1" face="Verdana, Arial, Helvetica, sans-serif"> click to 
          cancel or go previous</font> </div></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="27"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a> 
          click to print</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#BBBC81"> 
      <td height="30" colspan="7"><div align="center"><strong><font color="#FFFFFF">:: 
          LIST OF EXISTING LOAN CODE ::</font></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25"><div align="center"><font size="1">LOAN CODE</font></div></td>
      <td width="12%"><div align="center"><font size="1">SCHOOL YEAR</font></div></td>
      <td width="11%"><div align="center"><font size="1">SEMESTER</font></div></td>
      <td width="22%"><div align="center"><font size="1">LOAN TYPE</font></div></td>
      <td width="10%" height="25"><div align="center"><font size="1">INTEREST</font></div></td>
      <td width="18%"><div align="center"><font size="1">DATE OF 1ST INT. PAYMENT</font></div></td>
      <td width="17%"><div align="center"><font size="1">OPTIONS</font></div></td>
    </tr>
    <%for (int i = 0;i < vRetResult.size(); i+=14){%>
	<tr> 
      <td height="25">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td> <div align="center">
          <%=(String)vRetResult.elementAt(i+2)%>
          - 
          <%=(String)vRetResult.elementAt(i+3)%>
        </div></td>
      <td>
        <%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+4),"1"))]%>
      </td>
      <td> <%=astrLoanType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"))]%> 
      </td>
      <td height="25">
        <%=(String)vRetResult.elementAt(i+6)%>
		<%=astrUnit[Integer.parseInt((String)vRetResult.elementAt(i+7))]%>
		<%=astrFrequency[Integer.parseInt((String)vRetResult.elementAt(i+8))]%>
      </td>
      <td>&nbsp;
        <%if(((String)vRetResult.elementAt(i+5)).equals("0")){%>
		<%=astrConvertMonth[Integer.parseInt((String)vRetResult.elementAt(i+9))]%> <%=(String)vRetResult.elementAt(i+10)%>
		<%}%>
      </td>
      <td><div align="center"><font size="1">
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')">
	      <img src="../../../images/edit.gif" border=0 >
	  </a>
	  <a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+1)%>')"><img src="../../../images/delete.gif" border="0"></a></font></div></td>
    </tr>
	<%}%>
  </table>
  <%}// end if vRetResult != null %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>  
  <input type="hidden" name="print_page">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>