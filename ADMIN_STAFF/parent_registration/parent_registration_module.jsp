<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,enrollment.ParentRegistration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>

<script language="JavaScript">


var calledRef;
var strCalledCount;
function AjaxMapName(strCount) {
	//calledRef = strRef;
	var strCompleteName;
	strCalledCount = strCount
	strCompleteName = eval('document.form_.stud_name_'+strCount+'.value');
	if(strCompleteName.length <3)
		return;

	
	/// this is the point i must check if i should call ajax or not..
	if(this.bolReturnStrEmpty && this.startsWith(this.strPrevEntry,strCompleteName, false) == 0)
		return;
	this.strPrevEntry = strCompleteName;
	
	var objCOAInput;
	objCOAInput = document.getElementById("coa_info_"+strCount);
	//objCOAInput = eval('document.form_.coa_info_'+strCount);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&name_format=5&complete_name="+escape(strCompleteName);
	

	this.processRequest(strURL);
	//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}

function UpdateID(strID, strUserIndex) {		
		var strTemp = eval('document.form_.stud_name_'+strCalledCount);		
		strTemp.value = strID;	
		document.getElementById("coa_info_"+strCalledCount).innerHTML = "";
		//this.ReloadPage();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
	/**if(calledRef == "1") {
		document.form_.payee_name.value = strName;
		document.getElementById("coa_info").innerHTML = "";
	}*/
}

function updateList(){
	var pgLoc = "./manage_gsm_prefix.jsp";			
	var win=window.open(pgLoc,"PrintPg",'width=800,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}


function ReloadPage() {
	document.form_.submit();
}

function RegisterEntry(){
	//document.form_.search_.value='1';
	document.form_.page_action.value='1';
	document.form_.submit();
 }

function DisplayStud(){
	var oldvalue = document.form_.old_value.value;
	var newvalue = document.form_.no_of_children.value;
	
	if(oldvalue == newvalue)
		return;

	if(document.form_.no_of_children.value == '')
		return;
		
	document.form_.old_value.value = document.form_.no_of_children.value;
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PARENT REGISTRATION"),"0"));		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

int iSearchResult = 0;

Vector vRetResult = new Vector();
ParentRegistration prSMS = new ParentRegistration();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	vRetResult = prSMS.operateOnSPCParentRegModule(dbOP, request, 1);
	if(vRetResult == null)
		strErrMsg = prSMS.getErrMsg();
	else
		strErrMsg = "Entry Successfully Added";
}

String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSem    = (String)request.getSession(false).getAttribute("cur_sem");

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>
<form action="./parent_registration_module.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PARENT'S REGISTRATION PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
		<td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
		<td width="25%" colspan="2" align="right"><a href="main.jsp"><img src="../../images/go_back.gif" border="0"></a></td>
	</tr>
</table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>       
      <td  colspan="6" height="25"><strong>Parent's Name</strong></td>
    </tr>
	<tr>
      <td width="2%">&nbsp;</td>       
      <td width="16%" align="right">Last Name &nbsp;</td>	  
	  <td colspan="3"><input type="text" name="last_name" value="<%=WI.fillTextValue("last_name")%>" 
			  	class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/> </td>
    </tr>
	
	<tr>
	  <td valign="top">&nbsp;</td>  
		
	 	<td width="16%" align="right">First Name &nbsp;</td>
	 	<td colspan="3"><input type="text" name="first_name" value="<%=WI.fillTextValue("first_name")%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/>  </td>
    </tr>
	
	<tr>
	  <td valign="top">&nbsp;</td> 
      
      <td width="16%" align="right">Middle Name &nbsp;</td>
      <td colspan="3"><input type="text" name="middle_name" value="<%=WI.fillTextValue("middle_name")%>" 
	  			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/></td>	  	  
    </tr>
	
	
	<tr><td colspan="6">&nbsp;</td></tr>
	<tr>       
      <td  colspan="6" height="25"><strong>Login Information </strong></td>
    </tr>
	<tr>
	  <td align="right">&nbsp;</td>       
      <td width="16%" align="right">Login ID &nbsp;</td>	  
	  <td colspan="3"><input type="text" name="login_id" value="<%=WI.fillTextValue("login_id")%>" 
			  	class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/></td>
    </tr>
	<tr>
	  <td align="right">&nbsp;</td>       
      <td width="16%" align="right">Password &nbsp;</td>	  
	  <td colspan="3"><input type="password" name="password" value="<%=WI.fillTextValue("password")%>" 
			  	class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/></td>
    </tr>
	<tr>
	  <td align="right">&nbsp;</td>       
      <td width="16%" align="right">Confirm Password &nbsp;</td>	  
	  <td colspan="3"><input type="password" name="confirm_password" value="<%=WI.fillTextValue("confirm_password")%>" 
			  	class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/></td>
    </tr>
	
	<tr><td colspan="6">&nbsp;</td></tr>
	<tr>
	  <td>&nbsp;</td>
		<td align="right">Contact Number(Mobile) &nbsp;</td>
		<td colspan="3">
		<input type="text" name="mobile_parent_no" 			
			 value="<%=WI.fillTextValue("mobile_parent_no")%>" 
			 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/>		</td>
	</tr>
<!--
	<tr>
		<td colspan="2" height="25">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("reg_sms_services");
		if(strTemp.equals("1"))
			strTemp = "checked";
		else
			strTemp = "";
		%>
		<td>
		<input type="checkbox" name="reg_sms_services" value="1" <%=strTemp%> > Click if number will be registered for SMS services		</td>
	</tr>
-->	
	
	<tr><td colspan="6">&nbsp;</td></tr>
	
	
	
	<tr>
			<td height="15" colspan="6">
			
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr><td height="25" colspan="4"><strong>Contact Address</strong></td></tr>
						<tr>
						  <td width="3%">&nbsp;</td>
							<td height="25" width="20%">House no./ Street / Barangay </td>
							<td height="25">
								<input name="contact_address" type="text" value="<%=WI.fillTextValue("contact_address")%>" 
									size="72" class="textbox" maxlength="128"
									onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';"></td>
						</tr>
						<tr>
						  <td>&nbsp;</td>
							<td>City/Town/Province/Zip</td>
							<td>							
							<input name="contact_address_city" type="text" value="<%=WI.fillTextValue("contact_address_city")%>" 
							size="72" class="textbox" maxlength="128" 
							onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';">							</td>
						</tr>
					<tr>
					  <td>&nbsp;</td>	
						<td>Email : </td>
						<td colspan="3"><input type="text" name="email_address" value="<%=WI.fillTextValue("email_address")%>" 
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white';"/></td>
					</tr>
					<tr>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td colspan="3">&nbsp;</td>
				  </tr>
					<tr>
					  <td>&nbsp;</td>
					  <td>Assigned RF ID </td>
					  <td colspan="3">
					  <input type="text" name="rf_id1" value="<%=WI.fillTextValue("rf_id1")%>" 
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white';"/>
						</td>
				  </tr>
				</table>				</td>
		</tr>
	
	
	<tr><td colspan="6">&nbsp;</td></tr>
	<tr>
	  <td>&nbsp;</td>
		<td height="25">&nbsp;</td>
		<%
		int iNoOfChild = Integer.parseInt(WI.getStrValue(WI.fillTextValue("no_of_children"),"1"));
		%>
		<td colspan="5">No. of student to register <input type="text" name="no_of_children" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','no_of_children');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','no_of_children'); DisplayStud();" size="3" maxlength="5" value="<%=iNoOfChild%>"/>		</td>
	</tr>
	
	
	<%
	
	//int iNoOfChild = Integer.parseInt(WI.getStrValue(WI.fillTextValue("no_of_children"),"0"));
	
	if(iNoOfChild > 0){	
	%>
	
	<tr>
	  <td>&nbsp;</td>
		<td height="25">&nbsp;</td>
		<td valign="bottom">Student Name or ID</td>
		<td colspan="2" valign="bottom">Relation to Student</td>
	</tr>
	
	<%
	for(int i = 1; i <= iNoOfChild; i++){
	%>
	
	<tr>
	  <td width="3%" align="right">&nbsp;</td>
		<td height="25" width="10%" align="right"><%=i%>. &nbsp;</td>
		<td width="19%">
			<input type="text" name="stud_name_<%=i%>" value="<%=WI.fillTextValue("stud_name_"+i)%>" onKeyUp="AjaxMapName('<%=i%>');"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/></td>
				
		<td>
		
		<select name="relationship_<%=i%>">
        <option value=""></option>
<%
strTemp = WI.fillTextValue("relationship_"+i);

if(strTemp.equals("Father"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="Father" <%=strErrMsg%> >Father</option>
<%
if(strTemp.equals("Mother"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="Mother"<%=strErrMsg%> >Mother</option>
<%
if(strTemp.equals("Guardian"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="Guardian"<%=strErrMsg%>>Guardian</option>
      </select>	&nbsp; &nbsp; <label id="coa_info_<%=i%>" style="width:300px; position:absolute;"></label>	</td> 		
		
		
	</tr>
	
	<%}%>
	
	
	
	<tr><td colspan="5">&nbsp;</td></tr>
	
	<%}%>
	
	<tr>	
		<td colspan="5" align="center">
	  	<input type="button" name="1" value=" CREATE " 
			style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="RegisterEntry();">	  </td>
	</tr>
  </table>
  
  
  

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_" value="">
<input type="hidden" name="page_action">
<input type="hidden" name="old_value" value="<%=WI.getStrValue(WI.fillTextValue("old_value"),"1")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>