<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDFormBC,chedReport.CHEDFormBC"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	if (WI.fillTextValue("print_page").equals("1")){
%>
	<jsp:forward page="./ched_form_b_c_print.jsp?show_details=1" />
<%
	return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED E-FORM B/C</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<script language="JavaScript">
function ReloadPage(){
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function ChangeProgram(){
	document.form_.prepareToEdit.value ="0";
	document.form_.print_page.value="0";	
	if (document.form_.course_index) 
		document.form_.course_index.selectedIndex = 0;
	 if(document.form_.major_index)
		document.form_.major_index.selectedIndex = 0;
	this.SubmitOnce("form_");
}
	


function AddNewRecord(){
	document.form_.page_action.value="1";
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value="2";
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function DeleteRecord(index){
	document.form_.page_action.value="0";
	document.form_.info_index.value = index;
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function CancelEdit()
{
	location = "./ched_form_b_c.jsp?sy_from=" + document.form_.sy_from.value + 
				"&sy_to=" + document.form_.sy_to.value;
}

function viewList(tablename,labelname,strFormField){
	var loadPg = "./ched_updatelist.jsp?tablename=" + tablename + "&labelname="+escape(labelname)+
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CHED REPORTS-CHED FORM B C","ched_form_b_c.jsp");
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

Vector vRetResult = null;
CHEDFormBC cip = new CHEDFormBC();
int i =0;

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (WI.fillTextValue("sy_from").length() == 4){  
	vRetResult = cip.getGraduatesPerCourse(dbOP,request);
			
	if (vRetResult == null && cip.getErrMsg() != null) {
		strErrMsg = cip.getErrMsg();
	}

}


%>
<body>
<form name="form_" action="./ched_graduates_per_course.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Arial, Helvetica, sans-serif"><strong>CHED 
          FORM B / C </strong> </font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <!--DWLayoutTable-->
    <tr> 
      <td width="123" height="25" class="body_font">&nbsp;Academic Year</td>
      <td width="848"> <% 
	strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length()  < 4){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUP="DisplaySYTo('form_','sy_from','sy_to')">
        to 
     <% 
		strTemp = WI.fillTextValue("sy_to");
	
	if (strTemp.length() < 4 ){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
        &nbsp;&nbsp; <input type="image" src="../../../images/form_proceed.gif" border="0"> 
      </td>
    </tr>
    <tr>
      <td height="25" class="body_font"><!--DWLayoutEmptyCell-->&nbsp;</td>
      <td><!--DWLayoutEmptyCell-->&nbsp;</td>
    </tr>
  </table>
<% if ( vRetResult != null && vRetResult.size() > 0) {%>
  <table width="85%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBE8DC"> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><strong>GRADUATES 
          DATA </strong></div></td>
    </tr>
    <tr> 
      <td width="56%"  height="25" class="thinborder"><div align="center"><strong>COURSE 
          :: MAJOR <br>
          </strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong>MALE</strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong>FEMALE</strong></div></td>
    </tr>
<%
	String strCurrCourse = null;
	String strCurrMajor = null;
for (i= 0 ; i < vRetResult.size() ;) {
	strCurrCourse = (String)vRetResult.elementAt(i);
	strCurrMajor = WI.getStrValue((String)vRetResult.elementAt(i+1),"");
	
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp; <%=strCurrCourse + WI.getStrValue(strCurrMajor," :: ","","")%> </td>
	  <% if (strCurrCourse.equals((String)vRetResult.elementAt(i)) && 
	  		 strCurrMajor.equals(WI.getStrValue((String)vRetResult.elementAt(i+1),"")) &&
			 ((String)vRetResult.elementAt(i+2) != null) && 
			 ((String)vRetResult.elementAt(i+2)).equals("M"))	{
			 
			 strTemp = (String)vRetResult.elementAt(i+3);
			 i+=4;
		 }else{
		 	strTemp = "0";
		 }
	  %>
      <td class="thinborder"><div align="center">&nbsp;<%=strTemp%></div></td>
	  <% if ( i < vRetResult.size() &&  
	         strCurrCourse.equals((String)vRetResult.elementAt(i)) && 
	  		 strCurrMajor.equals(WI.getStrValue((String)vRetResult.elementAt(i+1),"")) &&
			 ((String)vRetResult.elementAt(i+2) != null) && 
			 ((String)vRetResult.elementAt(i+2)).equals("F"))	{
			 
			 strTemp = (String)vRetResult.elementAt(i+3);
			 i+=4;
		 }else{
		 	strTemp = "0";
		 }
	  %>
      <td class="thinborder"><div align="center">&nbsp;<%=strTemp%></div></td>
    </tr>
<%} // end for loop%>
  </table>

<%} // if vRetREsult != null %>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="print_page" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
