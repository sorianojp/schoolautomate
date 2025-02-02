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
function AddEntry(){
	var strContactNo = document.form_.contact_no.value;
	var strEmailAdd = document.form_.email_address.value;
	
	if(strContactNo.length == 0 && strEmailAdd.length == 0){
		alert('Please provide Contact Number/Email Address');
		return ;
	}
	
		var pgLoc = "./additional_entry.jsp?contact_no="+strContactNo+"&email_address="+strEmailAdd;			
		var win=window.open(pgLoc,"PrintPg",'width=800,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	
}

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
		this.ReloadPage();
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


function ReloadPage() {
	//document.form_.searchStudent.value = "";
	//document.form_.print_pg.value = "";
	this.SubmitOnce("form_");
}


function Search(){
	document.form_.search_.value = '1';
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == '0')
		if(!confirm('Do you want to delete this id '+strInfoIndex+' in this account? '))
			return;
			
	document.form_.page_action.value = strAction;
	
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.submit();

}
</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
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
Vector vParentDetail = new Vector();

ParentRegistration prSMS = new ParentRegistration();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(prSMS.operateOnSPCParentRegModule(dbOP, request, Integer.parseInt(strTemp)) == null )
		strErrMsg = prSMS.getErrMsg();
	else
		strErrMsg = "Entry successfully deleted";
}
String strEmailAdd = WI.fillTextValue("email_address");
String strContactNo = WI.fillTextValue("contact_no");

strTemp = WI.fillTextValue("search_");
if(strTemp.length() > 0){
	vParentDetail = prSMS.getParentDetail(dbOP, request, strContactNo, strEmailAdd);
	if(vParentDetail == null)
		strErrMsg = prSMS.getErrMsg();
	else{
		vRetResult = prSMS.operateOnSPCParentRegModule(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = prSMS.getErrMsg();	
	}
	
	
		
}

String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSem    = (String)request.getSession(false).getAttribute("cur_sem");

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>
<form action="./view_registered_sms.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PARENT  REGISTERED PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="15%" >Contact No.</td>	  
	  <td><input type="text" name="contact_no" value="<%=WI.fillTextValue("contact_no")%>" 
			  	class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/></td>
    </tr>
	
	<tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="15%" >Email Address</td>	  
	  <td><input type="text" name="email_address" value="<%=WI.fillTextValue("email_address")%>" 
			  	class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/></td>
    </tr>
	
	<tr><td colspan="3">&nbsp;</td></tr>
	
	<tr>
		<td>&nbsp;</td>
		<td colspan="2">
			<a href="javascript:Search()">
			<img src="../../images/form_proceed.gif" border="0"></a>			
			<font size="1">Click to search student for registered SMS</font>
		</td>
		
	</tr>
  </table>
  
  
  
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="right" colspan="3"><input type="submit" name="1" value=" ADD STUDENT ENTRY " 
			style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="AddEntry();"></td></tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td colspan="2"><strong>PARENT/GUARDIAN BASIC INFORMATION</strong></td>
	</tr>
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Parent Name </td>
		<td><strong><%=WI.getStrValue((String)vParentDetail.elementAt(0))%></strong></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Contact No.</td>
		<td><strong><%=WI.getStrValue((String)vParentDetail.elementAt(1))%></strong></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Email Address</td>
		<td><strong><%=WI.getStrValue((String)vParentDetail.elementAt(2))%></strong></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Relation</td>
		<td><strong><%=WI.getStrValue((String)vParentDetail.elementAt(3))%></strong></td>
	</tr>
	<tr><td colspan="3">&nbsp;</td></tr>
</table>
 
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	
	<tr><td align="center" height="25" colspan="6"  class="thinborder"><strong>SEARCH RESULT</strong></td></tr>
	<tr>
		<td width="10%" height="25" align="center"  class="thinborder"><strong>Count</strong></td>
		<td width="15%"  class="thinborder"><strong>ID Number</strong></td>
		<td width="40%"  class="thinborder"><strong>Full Name</strong></td>
		<td width="25%" class="thinborder"><strong>Course/Grade Level & Year</strong></td>
		<td class="thinborder"><strong>Option</strong></td>
	</tr>
	
	<%
	int iCount = 1;
	
	for(int i = 0; i < vRetResult.size() ; i+=5){
	%>
	<tr>
		<td height="25"  class="thinborder" align="center"><%=iCount++%></td>
		<td  class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i))%></td>
		<td  class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></td>
		
		<%
		strTemp = "-"+(String)vRetResult.elementAt(i+4);
		
		if(((String)vRetResult.elementAt(i+2)).equals("0"))
			strTemp = "";
		
		strTemp = (String)vRetResult.elementAt(i+3) + strTemp;
		%>
		
		<td  class="thinborder"><%=WI.getStrValue(strTemp)%></td>
		<td class="thinborder">		
			<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');"	>
			<img src="../../images/delete.gif" border="0"></a>
		</td>
	</tr>
	
	<%}%>
	
</table>
  
  
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>