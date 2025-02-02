<%@ page language="java" import="utility.*,java.util.Vector,hr.HRApplReference"%>
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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size:11px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
	document.staff_profile.reload_page.value = "1";
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src="../../../images/blank.gif";
	document.staff_profile.submit();
}

function EditRecord(){
	document.staff_profile.page_action.value="2";
	document.staff_profile.submit();
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
}

function CancelRecord(strApplID)
{
	location = "./hr_applicant_reference.jsp?appl_id="+strApplID;
}

function viewList(table,indexname,colname,labelname){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.staff_profile.appl_id.focus();
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
								"Admin/staff-APPLICANT - Reference","hr_applicant_reference.jsp");

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
														"hr_applicant_reference.jsp");
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
Vector vEditInfo = null;

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
boolean bolShowEditInfo = false;//true only if preparet to Edit is called and reload page is not called.


hr.HRApplNew hrApplNew = new hr.HRApplNew();
HRApplReference hrApplReference = new HRApplReference();
strTemp = WI.fillTextValue("appl_id");
if(strTemp.length() > 0){
	vApplicantInfo = hrApplNew.operateOnApplication(dbOP, request,3);//view one.
	if(vApplicantInfo == null)
		strErrMsg = hrApplNew.getErrMsg();
}

if (vApplicantInfo != null && vApplicantInfo.size() > 0){//proceed here.


	if(WI.fillTextValue("page_action").length() > 0) {//add, edit or delete.
		int iAction = Integer.parseInt(WI.fillTextValue("page_action"));
		vRetResult = hrApplReference.operateOnApplReference(dbOP, request,iAction);
		if(vRetResult != null && vRetResult.size() > 0){
			strPrepareToEdit = "0";
			if(iAction == 0)
				strErrMsg = "Applicant reference information removed successfully.";
			else if(iAction == 1)
				strErrMsg = "Applicant reference information added successfully.";
			else if(iAction == 2)
				strErrMsg = "Applicant reference information changed successfully.";
		}
	}
	else
		vRetResult = hrApplReference.operateOnApplReference(dbOP, request,4);
	if(vRetResult == null || vRetResult.size() == 0)
		strErrMsg = hrApplReference.getErrMsg();
}//end of if vapplication info is not null;

//check if Edit is called.
if(strPrepareToEdit.equals("1") && WI.fillTextValue("reload_page").equals("1")) {
	//edit is called.
	vEditInfo = hrApplReference.operateOnApplReference(dbOP,request,4);
	if(vEditInfo == null || vEditInfo.size() ==0)
		strErrMsg = hrApplReference.getErrMsg();
	else
		bolShowEditInfo = true;
}

if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	
strTemp = WI.getStrValue(strTemp);
%>

<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_applicant_reference.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          REFERENCE RECORD PAGE ::::</strong></font></div></td>
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
      <td width="54%"><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%
if(vApplicantInfo != null && vApplicantInfo.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
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
        </table>
        <br> <table width="92%" border="0" align="center">
          <tr>
            <td width="69">&nbsp;</td>
            <td>Reference Name</td>
            <td>
<%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("reference_name");
%>

			<input name="reference_name" type= "text" value="<%=strTemp%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="64"></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>Company</td>
            <td>
<%
if(bolShowEditInfo)
	strTemp = WI.getStrValue(vEditInfo.elementAt(2));
else
	strTemp = WI.fillTextValue("company_name");
%>
              <input name="company_name" type= "text" value="<%=strTemp%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="64"></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>Position</td>
            <td>
<%
if(bolShowEditInfo)
	strTemp = WI.getStrValue(vEditInfo.elementAt(3));
else
	strTemp = WI.fillTextValue("position");
%>
              <input name="position" type= "text" value="<%=strTemp%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="64"></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td width="209">Email Add</td>
            <td width="597">
 <%
if(bolShowEditInfo)
	strTemp = WI.getStrValue(vEditInfo.elementAt(4));
else
	strTemp = WI.fillTextValue("email");
%>
                <input name="email" type= "text" value="<%=strTemp%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="32">

            </td>
          </tr>
          <tr>
            <td width="69" height="26">&nbsp;</td>
            <td>Contact Number</td>
            <td>
<%
if(bolShowEditInfo)
	strTemp = WI.getStrValue(vEditInfo.elementAt(5));
else
	strTemp = WI.fillTextValue("contact_no");
%>
              <input name="contact_no" type= "text" value="<%=strTemp%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="64"></td>
          </tr>
<!--
          <tr>
            <td>&nbsp;</td>
            <td>Relation</td>
            <td>
              <%
//if(bolShowEditInfo)
//	strTemp = (String)vEditInfo.elementAt(7);
//else
//	strTemp = WI.fillTextValue("relation");
%>
              <select name="relation">
                <option value="">Select Relationship</option>
                <%//=dbOP.loadCombo("RELATION_INDEX","RELATION_NAME"," FROM HR_PRELOAD_RELATION",strTemp,false)%>
              </select> <a href='javascript:viewList("HR_PRELOAD_RELATION","RELATION_INDEX","RELATION_NAME","RELATIONSHIP");'>
              <img src="../../../images/update.gif" border="0"></a></td>
          </tr>
-->
          <tr>
            <td colspan="3"> <div align="center">
                <% if (iAccessLevel > 1){
	if(strPrepareToEdit.compareTo("1") != 0) {%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
                <font size="1">click to save entries&nbsp;
                <%}else{%>
                <a href='javascript:CancelRecord("<%=WI.fillTextValue("appl_id")%>");'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                to cancel and clear entries</font></font> <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
                <font size="1">click to save changes</font>
                <%}
		}//iAccessLevel > 1%>
              </div></td>
          </tr>
        </table>
        <br>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
        <table width="95%" border="0" align="center" cellpadding="3" cellspacing="0" class="thinborder">
          <tr>
            <td height="25" colspan="6" bgcolor="#C0C0C0" class="thinborder"><div align="center"><strong>LIST
            OF REFERENCES</strong></div></td>
          </tr>
          <tr>
            <td width="32%" height="25" class="thinborder"><strong> Reference </strong></td>
            <td width="24%" class="thinborder"><strong>Email Address</strong></td>
            <td width="28%" class="thinborder"><strong>Contact Number</strong></td>
<!--
            <td width="22%"><font size="1">Relation with the Applicant</font></td>
-->
            <td colspan="2" class="thinborder"><div align="center"><strong>Options</strong></div></td>
          </tr>
<%
for(int i = 0; i< vRetResult.size() ; i+= 8){%>
          <tr>
            <td class="thinborder"><font size="1"><strong><font color="#0000FF"><%=(String)vRetResult.elementAt(i + 1)%></font></strong>
              <%=WI.getStrValue((String)vRetResult.elementAt(i + 3), "<br>","<br>","")%><!--position-->
              <%=WI.getStrValue((String)vRetResult.elementAt(i + 2), "<br>","")%><!--contact address.-->
            </font></td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 4))%></td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 5))%></td>
<!--
            <td><font size="1"> <%=WI.getStrValue(vRetResult.elementAt(i + 6))%></font></td>
-->
            <td width="7%" class="thinborder"><input type="image" onClick='PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");' src="../../../images/edit.gif"></td>
            <td width="9%" class="thinborderBOTTOM"> <input type="image" onClick='DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");' src="../../../images/delete.gif"></td>
          </tr>
<%}%>
        </table>
<%}//only if vRetResult is not null;
%>
      </td>
    </tr>
  </table>
<%}%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>

    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="reload_page">
</form>
</body>
</html>

