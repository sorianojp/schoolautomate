<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage(strShowStat){
	document.form_.show_statistics.value = strShowStat;
	document.form_.print_page.value = "";
	document.form_.submit();
}

function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

function PrintInterview(strStudId) {
	if(strStudId.length == 0){
		alert("Student ID not found.");
		return;
	}
	

	var pgURL = "./exit_interview_print.jsp?stud_id="+strStudId+
	"&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AjaxMapName() {
		var strCompleteName = document.form_.stud_id.value;
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
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=-1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./exit_interview_stud_list_print.jsp"></jsp:forward>
	<%return;}
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other","exit_interview_mgmt.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	
	

osaGuidance.GDExitInterview gdExitInterview = new osaGuidance.GDExitInterview();
Vector vRetResult = null;
int iSearchResult = 0;	

if(WI.fillTextValue("show_statistics").length() > 0)	{
	vRetResult = gdExitInterview.generateExitInterviewReport(dbOP, request);
	if(vRetResult == null)
		strErrMsg = gdExitInterview.getErrMsg();
	else
		iSearchResult = gdExitInterview.getSearchCount();		
}
	
	
%>
<body bgcolor="#D2AE72">
<form action="exit_interview_mgmt.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          GUIDANCE EXIT INTERVIEW REPORT PAGE ::::</strong></font></div></td>
    </tr>
	<tr bgcolor="#FFFFFF"><td width="88%" height="25" style="padding-left:30px;"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
	    <td width="12%" align="right">
		<a href="main.jsp"><img src="../../../../../images/go_back.gif" border="0"></a>		</td>
	</tr>
</table>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">SY-Term</td>
		<td>
		<%	strTemp = WI.fillTextValue("sy_from");
			if(strTemp.length() ==0) 
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
		<%	strTemp = WI.fillTextValue("sy_to");
			if(strTemp.length() ==0) 
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		%>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
	  &nbsp;	  
	   <select name="semester">
	<%	strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		if(strTemp.equals("0"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="0" <%=strErrMsg%>>Summer</option>
	<%	if(strTemp.equals("1"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="1" <%=strErrMsg%>>1st Sem</option>
	<%	if(strTemp.equals("2"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="2" <%=strErrMsg%>>2nd Sem</option>
	<%	if(strTemp.equals("3"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="3" <%=strErrMsg%>>3rd Sem</option>
	<%	if(strTemp.equals("4"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="4" <%=strErrMsg%>>4th Sem</option>
        </select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>College</td>
	    <td>
			<select name="c_index_con" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select Any</option>
				<%=dbOP.loadCombo("c_index"," c_name "," from college where is_del = 0 ",WI.fillTextValue("c_index_con"), false)%>
			</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Course</td>
	    <td>
			<select name="course_index" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select All</option>
				<%	strTemp = " from COURSE_OFFERED where IS_VALID =1 and IS_OFFERED = 1 ";
					if(WI.fillTextValue("c_index").length() > 0)
						strTemp += " and c_index = "+WI.fillTextValue("c_index");
					strTemp += " order by course_code";
				%>
				<%=dbOP.loadCombo("course_index"," course_code, course_name ",strTemp,WI.fillTextValue("course_index"), false)%>
			</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Major</td>
	    <td>
			<select name="major_index" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select All</option>
				<%	
				if(WI.fillTextValue("course_index").length() > 0){
				strTemp = " from major where is_del =0 and course_index = "+WI.fillTextValue("course_index")+
					"order by course_code";
				%>
				<%=dbOP.loadCombo("major_index"," course_code, major_name ",strTemp,WI.fillTextValue("major_index"), false)%>
				<%}%>
			</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Year Level</td>
	    <td>
		<select name="year_level" onChange="ReloadPage('');">
			<option value="">Select Any</option>
			<%	strTemp = WI.fillTextValue("year_level");
				if(strTemp.equals("1"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="1" <%=strErrMsg%>>1st Year</option>
			<%	if(strTemp.equals("2"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="2" <%=strErrMsg%>>2nd Year</option>
			<%	if(strTemp.equals("3"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="3" <%=strErrMsg%>>3rd Year</option>
			<%	if(strTemp.equals("4"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="4" <%=strErrMsg%>>4th Year</option>
			<%	if(strTemp.equals("5"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="5" <%=strErrMsg%>>5th Year</option>
			<%	if(strTemp.equals("6"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="6" <%=strErrMsg%>>6th Year</option>
		</select>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>ID Number</td>
	    <td>
		<input name="stud_id" type="text" size="16" class="textbox" value="<%=WI.fillTextValue("stud_id")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();"> 
	  &nbsp; <label id="coa_info" style="position:absolute; width:400px;"></label> 
		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>
		<a href="javascript:ReloadPage('1');"><img src="../../../../../images/form_proceed.gif" border="0"></a>		</td>
	</tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td  colspan="2" align="right">
	<a href="javascript:PrintPage();"><img src="../../../../../images/print.gif" border="0"></a>
	<font size="1">Click to print list of student</font>
	</td></tr>
	<tr>
		<td colspan="2" height="22" align="center" style="font-weight:bold">
		LIST OF STUDENT AVAILED EXIT INTERVIEW</td>
	</tr>
	
	
	<tr> 
			<td width="57%" class="thinborderBOTTOMLEFT">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(gdExitInterview.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td width="43%" height="25" class="thinborderBOTTOM"> &nbsp;
			<%
				int iPageCount = 1;

				if(gdExitInterview.defSearchSize != 0){
					iPageCount = iSearchResult/gdExitInterview.defSearchSize;		
					if(iSearchResult % gdExitInterview.defSearchSize > 0)
						++iPageCount;
				}


				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ReloadPage('1');">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
			<%}%> </td>
		</tr>
	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr style="font-weight:bold;">
    <td width="4%" height="24" class="thinborder" align="center">Sl. No</td>
    <td width="13%" class="thinborder"><div align="center">Student ID</div></td>
    <td width="24%" class="thinborder" align="center">Student Name</td>
    <td width="24%" class="thinborder"><div align="center">Course-Major</div></td>
    <td width="9%" class="thinborder"><div align="center">Gender</div></td>
    <td width="15%" class="thinborder"><div align="center">Applied Date</div></td>
    <td width="11%" class="thinborder"><div align="center">Option</div></td>
  </tr>
<%
int iStudCount= 0;
strTemp = WI.getStrValue(WI.fillTextValue("jumpto"),"0");
if(strTemp.equals("0"))
	strTemp = "1";
iStudCount = iStudCount +  (gdExitInterview.defSearchSize * (Integer.parseInt(strTemp) - 1) );
for(int i = 0; i<vRetResult.size();i += 11){// this is for page wise display.

%>
  <tr>
    <td height="21" class="thinborder" align="right"><%=++iStudCount%>.&nbsp;</td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
	<%
	strTemp = WebInterface.formatName((String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),(String)vRetResult.elementAt(i + 5),4);
	%>
    <td class="thinborder"><%=strTemp%></td>
	<%
	strTemp = WI.getStrValue(vRetResult.elementAt(i + 6))+WI.getStrValue((String)vRetResult.elementAt(i + 7)," - ","","");
	%>
    <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%
	strTemp =WI.getStrValue((String)vRetResult.elementAt(i + 10),"M").toLowerCase();
	if(strTemp.equals("m"))
		strTemp = "Male";
	else
		strTemp = "Female";
	%>
    <td align="center" class="thinborder"><%=strTemp%></td>
	<%
	strTemp =WI.getStrValue((String)vRetResult.elementAt(i + 9),"&nbsp;");
	%>
    <td align="center" class="thinborder"><%=strTemp%></td>
    <td align="center" class="thinborder">
	<a href="javascript:PrintInterview('<%=vRetResult.elementAt(i+2)%>')"><img src="../../../../../images/print.gif" border="0"></a>
	</td>
  </tr>
  <%}//end of print per page.%>
</table>

<%}//end of vRetResult!=null && vRetResult.size()>0%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>&nbsp;</td></tr>
	<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
<input type="hidden" name="show_statistics" value="">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>