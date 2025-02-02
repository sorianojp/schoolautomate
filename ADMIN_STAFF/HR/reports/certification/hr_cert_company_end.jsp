<%@ page language="java" import="utility.*, java.util.Vector,java.util.Calendar"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
WebInterface WI = new WebInterface(request);
String strErrMsg = null;
DBOperation dbOP = null;
String strTemp = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Benefits",
								"hr_cert_company_end.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"HR Management","REPORTS AND STATISTICS",
											request.getRemoteAddr(),"hr_cert_company_end.jsp");
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

Vector vEmpRec = null;
String strSalutation = null;
String str2Weeks = null;
String strNextDay = null;
String[] astrMonth ={"January", "February", "March", "April", "May", "June",
					  "July", "August", "September", "October", "November", "December"};
String strLeaveCredits = null;
boolean bolIsMale = false;
					  
hr.HRBenefitsMgmt bMgt = new hr.HRBenefitsMgmt(request);
hr.HRLeaveSetting hrSetting = new hr.HRLeaveSetting();
Vector vSignatories = hrSetting.operateOnLeaveSignatories(dbOP, request, 4, "103");
int iIndexOf = 0;
String strTemp2 = null;

if (WI.fillTextValue("show_list").equals("1") && WI.fillTextValue("emp_id").length()  > 0){

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	
	if (vEmpRec == null || vEmpRec.size()  == 0)	{
		strErrMsg = authentication.getErrMsg();
	}else{
 		bolIsMale = WI.getStrValue((String)vEmpRec.elementAt(4)).equals("0");
	
		strSalutation = dbOP.mapOneToOther("hr_info_personal left join hr_preload_salutation " +
								" on (hr_info_personal.salutation_index = " + 
								" hr_preload_salutation.salutation_index)","user_index",
								(String)vEmpRec.elementAt(0),"salutation","");

	    java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("MM/dd/yyyy");
	    java.util.Date date = null;
    	try {
			if ((String)vEmpRec.elementAt(6) != null) 
		        date = dateFormat.parse((String)vEmpRec.elementAt(6));
			else
		       strErrMsg = " No record of Date of Employment";				
    	}
	    catch(java.text.ParseException pExp)
    	{
	       strErrMsg = " No record of Date of Employment";
	       pExp.getMessage();
    	}

	    Calendar calendar = Calendar.getInstance();

	    if (date != null){
		      calendar.setTime(date);
	
			calendar.add(Calendar.YEAR,3);
			strNextDay = astrMonth[calendar.get(Calendar.MONTH)] + " " 
						+ calendar.get(Calendar.DAY_OF_MONTH) + ", " + 
						calendar.get(Calendar.YEAR);

			calendar.add(Calendar.DAY_OF_MONTH,14);
			str2Weeks = astrMonth[calendar.get(Calendar.MONTH)] + " " 
						+ calendar.get(Calendar.DAY_OF_MONTH) + ", " + 
						calendar.get(Calendar.YEAR);
		}else{	
			strNextDay =" (no record)";
			str2Weeks =" (no record)";			
		}

	}
}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css" />
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>HR Certification</title>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

label {
	color: #FF0000;
}

</style>

<script src="../../../../Ajax/ajax.js"></script>
<script language="Javascript">
function focusID(){
	if(document.form_.emp_id)
		document.form_.emp_id.focus();
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
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function ReloadPage() {
	document.form_.show_list.value="1";
}


function setLabelText(strLabelName, strLabel){
	var strOld = document.getElementById(strLabelName).innerHTML;
	var strNewValue = prompt(strLabel, strOld);
	
	if (strNewValue != null && strNewValue.length > 0)
		document.getElementById(strLabelName).innerHTML = strNewValue;
}


function printPage(){

	document.getElementById("header").deleteRow(0);	
	document.getElementById("header").deleteRow(0);
	document.getElementById("header").deleteRow(0);
	document.getElementById("header").deleteRow(0);	
	document.getElementById("header").deleteRow(0);	
	document.getElementById("header").deleteRow(0);	
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);	
	window.print();
	
}

</script>
</head>

<body onLoad="focusID();">

<form name="form_" method="post" action="./hr_cert_company_end.jsp">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="header">
  <tr>
    <td height="25" colspan="4">&nbsp;<a href="./hr_cert_common_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0" /></a><%=WI.getStrValue(strErrMsg, 
												"<font size=\"3\" color=\"#FF0000\"><strong>",
												"</strong></font>","")%></td>
  </tr>
  <tr>
    <td width="17%">&nbsp;Employee ID : </td>
    <td width="17%" height="25"><input name="emp_id" type="text" value="<%=WI.fillTextValue("emp_id")%>" size="16" class="textbox" 
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"/></td>
    <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
    <td width="61%"><input type="image" src="../../../../images/form_proceed.gif" width="81" height="21" border="0" onClick="ReloadPage()"><label id="coa_info" style="position:absolute;"></label></td>
  </tr>
  <tr>
		<%
			strTemp = WI.fillTextValue("show_addressee");
			if(strTemp.length() > 0)
				strTemp = "checked";
			else
				strTemp = "";
		%>
    <td height="20" colspan="4"><input type="checkbox" name="show_addressee" value="1" <%=strTemp%>>
    show addressee </td>
  </tr>
  
  <tr>
    <td height="20">Remarks</td>
		<%
			strTemp = WI.fillTextValue("remarks");
			if(strTemp.length() == 0)
				strTemp = "N.B. Valid only for the purpose stated ";
			 
		%>
    <td height="20" colspan="3">
			<input name="remarks" type="text" value="<%=strTemp%>" size="60" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			 style="font-size:10px"/></td>
    </tr>
  <tr>
    <td height="20">&nbsp;</td>
		<%
			strTemp = WI.fillTextValue("separated_reason");
		%>
    <td height="20" colspan="3"><input name="separated_reason" type="text" value="<%=strTemp%>" size="60" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			 style="font-size:10px"/></td>
    </tr>
  <tr>
    <td height="20" colspan="4"> &nbsp;&nbsp;
		<font style="font-size:11px">Items in <font color="#FF0000">RED</font> are editable for printing purposes only </font></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td height="20">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>  
</table>

<% if (vEmpRec != null && vEmpRec.size() > 0) {%> 
<table width="80%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td height="58" colspan="2" align="center">	<font size="4">C E R T I F I C A T I O N</font> </td>
  </tr>
  <tr>
    <td height="37" colspan="2"> 
			    <%if(WI.fillTextValue("show_addressee").length() > 0){%>
					<font size="3">To 
			    <label id="addressee" 
				onclick="setLabelText('addressee','Addressee ')">
				Whom It May Concern</label>
			    :</font><br />
					<%}%>					</td>
  </tr>
  <tr>
    <td colspan="2"><p>This is to certify that   <strong><%= WI.getStrValue(strSalutation) + " " + 
				WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2),
						 (String)vEmpRec.elementAt(3), 7)%></strong> has worked with <%=SchoolInformation.getSchoolName(dbOP,true,false)%>  as the company's   
      <% 
				strTemp = (String)vEmpRec.elementAt(13);
				if (strTemp == null)
					strTemp = (String)vEmpRec.elementAt(14);
					
				if (strTemp == null)
					strTemp = "(No Record)";
			%>
        <label id="emp_position"
				onClick="setLabelText('emp_position','Employee Position')">
				<%=(String)vEmpRec.elementAt(15)%></label> of			
     <label id="division_" onClick="setLabelText('division_','Employee Division')"><%=strTemp%></label> Division
       <% if ((String)vEmpRec.elementAt(6) != null) 
						strTemp = WI.formatDate((String)vEmpRec.elementAt(6),6);
				  else 
				  	strTemp = "(No record)";
			 %>
			 from 
		<label id="date_employment"
			onclick="setLabelText('date_employment','Date of Employment')"><%=strTemp%> to 
       <% if ((String)vEmpRec.elementAt(27) != null) 
						strTemp = WI.formatDate((String)vEmpRec.elementAt(27),6);
				  else 
				  	strTemp = " date";
			 %>		 
			 <%=strTemp%>		 </label>
		<strong>.		</strong></p>
      <p><%if(bolIsMale){%>His<%}else{%>Her<%}%> separation from the company was due to
			<label id="reason_" onClick="setLabelText('reason_','Reason for Separation')"> Voluntary Resignation</label>.</p>
      <p>Further, this certification is issued by the company to serve as CLEARANCE, of the above employee from whatever obligation 
        <%if(bolIsMale){%>
        he
        <%}else{%>
        she
        <%}%> 
        had with the company and likewise, the company had already paid and given all obligations, monetary and others, to the said employee.</p>
      <p>This is issued upon request of the above employee for <label id="purpose" 
				onclick="setLabelText('purpose','State Purpose')">
				whatever legitimate</label> purpose it may serve  
        <%if(bolIsMale){%>
him
<%}else{%>
her
<%}%>.</p><font size="3">&nbsp; </font><br />
       <font size="3">&nbsp; </font>		</td>
  </tr>
  <tr>
    <td width="65%"><div align="right"></div></td>
    <td width="35%">&nbsp;</td>
  </tr>
  <tr>
    <td height="76" valign="bottom"><strong><font size="3">
<label id="director" 
		onclick="setLabelText('director','HRDC Director')"> 
			<%
				strTemp = "&nbsp;";
				strTemp2 = "&nbsp;";
 				if(vSignatories != null && vSignatories.size() > 0){
					iIndexOf = vSignatories.indexOf(new Long(103));
					if(iIndexOf != -1){
						strTemp = (String)vSignatories.elementAt(iIndexOf+3);
						strTemp2 = (String)vSignatories.elementAt(iIndexOf+2);
					}
				}
				%>
		<%=WI.getStrValue(strTemp, "(Signatory)")%></label></font>
<font size="3"><br />
      <label id="position_" 
		onclick="setLabelText('position_','Signatory Position')"> <%=WI.getStrValue(strTemp2, "(Position)")%></label>
		</font></strong></td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr>
    <td height="45" valign="bottom">Date : <%=WI.getTodaysDate(6)%></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="45" valign="bottom"><font size="1"><%=WI.fillTextValue("remarks")%></font></td>
    <td>&nbsp;</td>
  </tr>
</table>
<br />
<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" id="footer">
  <tr>
    <td><hr /></td>
  </tr>
  <tr>
    <td><div align="center">
	<a href="javascript:printPage()"><img src="../../../../images/print.gif" width="58" height="26" border="0" /></a><font size="1">print letter </font></div></td>
  </tr>
  <tr>
    <td height="30"><font size="2"><strong>Note: Set Printer to black / white mode before printing</strong></font></td>
  </tr>
</table>
<%}%>

<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>" />
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
