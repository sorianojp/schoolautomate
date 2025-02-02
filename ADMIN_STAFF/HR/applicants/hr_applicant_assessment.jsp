<%@ page language="java" import="utility.*,java.util.Vector,hr.HRApplApplicationEval"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Applicant's Note Card</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function viewInfo(){
	document.staff_profile.page_action.value = "3";
}
function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src="../../../images/blank.gif";
	document.staff_profile.submit();
}
function DeleteRecord(strInfoIndex){
	if(!confirm('Are you sure you want to remove this record'))
		return;
		
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value=strInfoIndex;
	document.staff_profile.submit();
}

function EditRecord(){
	document.staff_profile.page_action.value="2";
	document.staff_profile.submit();
}
function CancelRecord(strApplID)
{
	location = "./hr_applicant_assessment.jsp";
}
function FocusID() {
	document.staff_profile.appl_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.evaluated_by";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-APPLICANT - Pre Intv Eval","hr_applicant_assessment.jsp");

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
														"HR Management","APPLICANTS DIRECTORY",request.getRemoteAddr(),
														"hr_applicant_assessment.jsp");
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

Vector vRetResult = new Vector();
Vector vApplicantInfo  = null;

boolean bolNoRecord = false;//true only if preparet to Edit is called and reload page is not called.


hr.HRApplNew hrApplNew = new hr.HRApplNew();
HRApplApplicationEval hrApplEval = new HRApplApplicationEval();
strTemp = WI.fillTextValue("appl_id");
if(strTemp.length() > 0){
	vApplicantInfo = hrApplNew.operateOnApplication(dbOP, request,3);//view one.
	if(vApplicantInfo == null)
		strErrMsg = hrApplNew.getErrMsg();
}

if (vApplicantInfo != null && vApplicantInfo.size() > 0){//proceed here.

	strTemp = WI.fillTextValue("page_action");
	//int iAction =  -1; -- updated Dec 02, 2014 to accommodate more than one interview.. 
	//iAction = Integer.parseInt(WI.getStrValue(strTemp,"3"));
	//vRetResult = hrApplEval.operateOnPreIntvEval(dbOP, request,iAction);
	if(strTemp.length() > 0) {
		int iAction = Integer.parseInt(strTemp);
		vRetResult = hrApplEval.operateOnPreIntvEval(dbOP, request,iAction);
		
		if(vRetResult != null && vRetResult.size() > 0){
			if(iAction == 0)
				strErrMsg = "Applicant application assessment information removed successfully.";
			else if(iAction == 1)
				strErrMsg = "Applicant application assessment information added successfully.";
			else if(iAction == 2)
				strErrMsg = "Applicant application assessment information changed successfully.";
		}
		else
			strErrMsg = hrApplEval.getErrMsg();
	}
}//end of if vapplication info is not null;

//view all reocrds. 
boolean bolShowCreateRecord = true;

if(vApplicantInfo != null) {
	vRetResult =  hrApplEval.operateOnPreIntvEval(dbOP, request,4);
	if(strErrMsg == null && vRetResult == null) 
		strErrMsg = "Interview Record not yet created.";
	else	
		bolShowCreateRecord = false;
}	
//if (vRetResult == null || vRetResult.size() == 0){
	bolNoRecord = true; //forced to true.. 
//}
//System.out.println(strErrMsg);
strTemp = WI.fillTextValue("appl_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_applicant_assessment.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>::::
          ASSESSMENT &amp; COMMENTS PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr >
      <td width="24%" height="28"><font size="1"><strong>&nbsp;&nbsp;</strong></font>Applicant's
        Reference ID : </td>
      <td width="22%"><input type="text" name="appl_id" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="18" value="<%=strTemp%>">
      </td>
      <td width="54%"><input name="image" type="image" src="../../../images/form_proceed.gif">
	  
	  &nbsp;&nbsp;
	  
	  <%if(vRetResult != null && vRetResult.size() > 0) {%>
	  	<input type="checkbox" name="create_more" value="checked" <%=WI.fillTextValue("create_more")%> onClick="document.staff_profile.page_action.value=''; document.staff_profile.submit()"> Create More Record
	  <%}%>
	  </td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%
if(vApplicantInfo != null && vApplicantInfo.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
<table width="526" height="77" border="0" align="center">
          <tr bgcolor="#FFFFFF">
            <td width="100%" valign="middle">
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.fillTextValue("appl_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
              <%=strTemp%><br> <br> <br> <strong><%=WI.formatName((String)vApplicantInfo.elementAt(1),(String)vApplicantInfo.elementAt(2),
						 				 (String)vApplicantInfo.elementAt(3),4)%></strong><br>
              Position Applying for: <%=WI.getStrValue(vApplicantInfo.elementAt(11))%><br>
              <%=WI.getStrValue(vApplicantInfo.elementAt(5),"<br>","")%>
              <!-- email -->
              <%=WI.getStrValue(vApplicantInfo.elementAt(4))%>
              <!-- contact number. -->
            </td>
          </tr>
        </table>        <br> 
<%if(bolShowCreateRecord || WI.fillTextValue("create_more").length() > 0) {%>
<table width="92%" border="0">
          <tr>
            <td width="11%">&nbsp;</td>
            <td width="15%">Assessed by</td>
            <td width="74%">
<%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(0);
else
	strTemp = WI.fillTextValue("evaluated_by");

Vector vTemp = new hr.HRInfoServiceRecord().getSupervisorDetail(dbOP,request,null,null,null);

%>
	<input type="text" name="starts_with2" value="<%=WI.fillTextValue("starts_with2")%>" size="25" class="textbox"
   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px" 
   onKeyUp = "AutoScrollList('staff_profile.starts_with2','staff_profile.evaluated_by',true)">

<select name="evaluated_by">
   <%if(vTemp != null && vTemp.size() > 0){
		for(int i = 0; i < vTemp.size(); i += 2) {
			if(strTemp.compareTo((String)vTemp.elementAt(i)) == 0){%>
                <option value="<%=(String)vTemp.elementAt(i)%>" selected> 
                <%=(String)vTemp.elementAt(i + 1)%></option>
            <%}else{%>
               <option value="<%=(String)vTemp.elementAt(i)%>"> 
        	   <%=(String)vTemp.elementAt(i + 1)%></option>
            <%} //end if else
	    } // end for loop
    } // end if (vTemp != null) %>
</select>            </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>Date</td>
            <td><%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(1);
else
	strTemp = WI.fillTextValue("evaluation_date");
%>
              <input name="evaluation_date" type= "text" class="textbox"  
		onFocus="style.backgroundColor='#D3EBFF'" size="12" value="<%=strTemp%>"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','evaluation_date','/')" 
		 onKeyUp="AllowOnlyIntegerExtn('staff_profile','evaluation_date','/')">
              <a href="javascript:show_calendar('staff_profile.evaluation_date');" 
		title="Click to select date" onMouseOver="window.status='Select date';return true"
		onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" 
		width="20" height="16" border="0"></a></td>
          </tr>
          
          <tr>
            <td width="11%">&nbsp;</td>
            <td colspan="2">Assessment:<br>
<%
if(!bolNoRecord)
	strTemp = WI.getStrValue(vRetResult.elementAt(2));
else
	strTemp = WI.fillTextValue("assessment_comments");
%>              <textarea name="assessment_comments" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			  cols="65" rows="2"><%=strTemp%></textarea>            </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td colspan="2">Comments/Remarks:<br>
<%
if(!bolNoRecord)
	strTemp = WI.getStrValue(vRetResult.elementAt(3));
else
	strTemp = WI.fillTextValue("remarks");
%>			<textarea name="remarks" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
			onblur="style.backgroundColor='white'" cols="65" rows="2"><%=strTemp%></textarea>            </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td colspan="2">Is Applicant suitable for Interview Call ?
 <%
if(!bolNoRecord)
	strTemp = (String)vRetResult.elementAt(4);
else
	strTemp = WI.fillTextValue("is_suitable");
if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>             <input type="checkbox" name="is_suitable" value="1"<%=strTemp%>></td>
          </tr>
        </table>
        <div align="center">
          <p>
            <% if (iAccessLevel > 1 ){
	if(bolNoRecord) {%>
            <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
            <font size="1">click to save entries&nbsp;
            <%}else{%>
            <a href='javascript:CancelRecord("<%=WI.fillTextValue("appl_id")%>");'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
            to cancel and clear entries</font></font> <a href="javascript:EditRecord();">
			<img src="../../../images/edit.gif" border="0"></a>
            <font size="1">click to save changes</font>
            <%}
		}//iAccessLevel > 1%>
          </p>
        </div>
<%}//show if bolShowCreateRecord or if create_more is clicked. %>
      </td>
    </tr>
<%}//only if applicant infomration exists.
%>
  </table>
  
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="6" align="center" bgcolor="#FFFFAA" class="thinborderALL"><strong>INTERVIEW RESULT</strong></td>
    </tr>
    <tr style="font-weight:bold"> 
      <td width="12%" height="25" align="center" class="thinborder">Date Of Evaluation</td>
      <td width="25%" height="25" align="center" class="thinborder">Evaluated By</td>
      <td width="28%" align="center" class="thinborder">Comments</td>
      <td width="7%" align="center" class="thinborder">Remarks</td>
      <td width="10%" align="center" class="thinborder">Is For Interview</td>
      <td width="8%" align="center" class="thinborder">DELETE</td>
    </tr>
<%
String[] astrConvertIntvStatus = {"--","Yes"};
for(int i = 0; i < vRetResult.size(); i += 6){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4),"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=astrConvertIntvStatus[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td align="center" class="thinborder">
	  <%
	  if(iAccessLevel ==2) {%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a></td>
     <%}%>
	</tr>
    <%}%>
  </table>
<%}%>


 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
