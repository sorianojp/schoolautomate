<%@ page language="java" import="utility.*,java.util.Vector,hr.HRCareerFeedback"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
}

function viewInfo(){
	document.staff_profile.page_action.value = "4";
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
}

function EditRecord(){

	document.staff_profile.page_action.value="2";
	document.staff_profile.submit();
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
}

function CancelRecord(index)
{
	location = "./hr_personnel_affiliations.jsp?emp_id="+index;
}

function viewList(table,indexname,colname,labelname){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.staff_profile.emp_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CAREER DEVELOPMENT-Upward Feedback","hr_career_feedback.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","CAREER DEVELOPMENT",request.getRemoteAddr(),
														"hr_caree_feedback.jsp");
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
Vector vRetResult = null;
HRCareerFeedback hrf  = new HRCareerFeedback();

strTemp = WI.fillTextValue("emp_id");

if (strTemp.trim().length()> 1){

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vEmpRec == null || vEmpRec.size() ==  0){
		strErrMsg = "Employee has no profile.";
	}else{
		vRetResult = hrf.operateOnCareerFeedback(dbOP, request, 4);
		
		if (vRetResult == null){
			strErrMsg = hrf.getErrMsg();
		}
	}
} 
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">

<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          UPWARD CAREER FEEDBACK PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="41%" height="25">&nbsp;&nbsp;Employee ID : 
        <input name="emp_id" type= "text" class="textbox" id="emp_id"  value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="10%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="49%"><input name="image2" type="image" onClick="viewInfo();" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
 <%if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1){ %>
      <td height="25" colspan="3"><hr width="100%" size="1" noshade>
	  <%=WI.getStrValue(strErrMsg,"")%>
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%> <%=WI.getStrValue(strTemp)%> <br> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%> <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> </td>
          </tr>
        </table>

        <br>
<% if (vRetResult != null && vRetResult.size() > 0) {%>
        <table width="95%" border="0" align="center" cellpadding="5" cellspacing="0">
          <tr> 
            <td colspan="2"><FONT face=verdana size=2>Superiors’s ID: 
              <SELECT name ="sup_id" >
               <option value="">Superior's ID</option>
                <%=dbOP.loadCombo("USER_INDEX","ID_NUMBER",
				" FROM USER_TABLE WHERE (AUTH_TYPE_INDEX <>4 and AUTH_TYPE_INDEX<>6) or AUTH_TYPE_INDEX is null ",null,false)%>

              </SELECT>
              <BR>
              <BR>
              </FONT><font size="1" face="Verdana, Arial, Helvetica, sans-serif">This 
              questionnaire is designed to provide your immediate superior’s Reviewer 
              with feedback. The information will be used by the reviewer to assist 
              the superior in developing his/her capabilities. Although the completion 
              of this form is optional, we encourage you to take this opportunity 
              to share feedback on your superior’s performance. In order to be 
              most helpful, please answer the questions in a candid manner.</font> 
            </td>
          </tr>
          <tr bgcolor="#333333"> 
            <td width="86%" bgcolor="#CCCCCC"><font color="#FF0000"><strong>UPWARD 
              FEEDBACK EVALUATION FORM</strong></font></td>
            <td width="14%" bgcolor="#CCCCCC"><strong><font color="#FF0000" size="1">N/C- 
              No Comment; <br>
              5 - Very well; <br>
              1 - Needs Improvement</font></strong></td>
          </tr>
</table>
<table width="95%" border="0" align="center" cellpadding="5" cellspacing="0">
<% for (int i = 0; i <vRetResult.size() ; i+=5) {
	if ((String)vRetResult.elementAt(i+1) !=null) {%>
          <tr> 
            <td colspan="2"> <strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
          </tr>
<%} strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3),"");
	if (strTemp.length() == 0) 
		strTemp = "&nbsp";
	else
		if ((String)vRetResult.elementAt(i+4) != null){
			strTemp = "( " + strTemp + " )";
		}
%>
          <tr> 
            <td width="89%"><%=strTemp%></td>
            <td width="11%"><select name="<%="rate"+(String)vRetResult.elementAt(i+4)%>">
                <option value=0 selected>N/C</option>
                <option 
                    value=1>1</option>
                <option value=2>2</option>
                <option 
                    value=3>3</option>
                <option value=4>4</option>
                <option 
                    value=5>5</option>
              </select></td>
          </tr>
<%} // end for loop %>
</table>
<table width="95%" align="center">
          <tr> 
            <td colspan="2"><p>&nbsp;</p>
              <p>What traits of your superiors’s style do you feel are most effective?<BR>
                <TEXTAREA  name=ans1 cols="64" rows="3" class="textbox" id=textarea onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></textarea>
                <BR>
                <BR>
                What traits of your supervisor’s style do you feel are least effective?<BR>
                <TEXTAREA id=textarea2  name=ans2 rows=3 cols=64 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></textarea>
                <BR>
                <BR>
                What specific things could your supervisor do that would enable 
                you to do your job more effectively?<BR>
                <TEXTAREA id=textarea3  name=ans3 rows=3 cols=64 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></textarea>
              </p></td>
          </tr>
        </table>
        <div align="center"> 
          <input name="hide_save" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
          <font size="1">click to save entries</font> <img src="../../../images/cancel.gif" width="51" height="26" border="0"><font size="1">click 
          to cancel and clear entries</font></div>
        <hr size="1"></td>
<% }// end if (vRetResult != null) 
 }//   if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1){ %>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="page_action">
</form>
</body>
</html>

