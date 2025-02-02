<%@ page language="java" import="utility.*,java.util.Vector,hr.HRApplApplicationEval"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Applicant Interview Result</title>
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
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
function viewInfo(){
	document.form_.page_action.value = "3";
}
function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src="../../../images/blank.gif";
	document.form_.submit();
}

function EditRecord(){
	document.form_.page_action.value="2";
	document.form_.submit();
}
function DeleteRecord(strAction){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strAction;
	document.form_.submit();
}
function CancelRecord(strApplID)
{
	location = "./interview_result.jsp";
}
function FocusID() {
	document.form_.appl_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.evaluated_by";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ShowHideDOJ(showStatus) {
	var strShowStat_;
	var  i =0; 
	if (showStatus == 2){

	var radioGrp = document.form_.intv_result;
	for (var i = 0; i< radioGrp.length; i++) {
	    if (radioGrp[i].checked) {
			if( i == 0 || i == 1  || i ==3) 
				showStatus = 0;
			else
				showStatus = 1;
	    }
	  }
	}
	
	if (showStatus == 2) 
		showStatus = 0;

//	alert("showStatus : " + showStatus);

	if(showStatus == 0) {//hide
		document.form_.probable_doj.value = "";
		hideLayer('probable_doj');
		hideLayer('hide_doj');
		hideLayer('probable_doj_tb');				
	}
	else {
		showLayer('probable_doj');
		showLayer('hide_doj');
		showLayer('probable_doj_tb');				
	}
}
function InstantiateDOJ() {
//	var vIntvResult = document.form_.intv_result.value;
//	var vShowStatus = 0;
//	if(vIntvResult == "1")
//		vShowStatus = 1;
//	this.showHideDOJ(vShowStatus);

}

function AddInterviewer()
{
	if (document.form_.evaluated_by.value.length == 0) {
		alert ("Please enter Interviewer ID");
		return;
	}

	if (document.form_.evaluation_date.value.length == 0){
		alert("Please enter date of enterview");
		return;
	}

	document.form_.add_fee.value = "1";
	document.form_.list_count.value = ++document.form_.list_count.value;
	document.form_.page_action.value="";
	document.form_.submit();
}

function RemoveFeeName(removeIndex)
{
	document.form_.remove_index.value = removeIndex;
	document.form_.page_action.value="";
	document.form_.submit();
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
								"Admin/staff-APPLICANT - Interview result.","interview_result.jsp");

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
														"interview_result.jsp");
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

Vector vRetResult = null;
Vector vApplicantInfo  = null;
Vector vEditInfo  = null;
Vector vInterviewers = null;

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
String strFirstEntry = WI.fillTextValue("first_entry");

if (strFirstEntry.length() == 0) 
	strFirstEntry = "0";


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
	int iAction;
	iAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));
	vRetResult = hrApplEval.operateOnInterviewResult(dbOP, request,iAction);
//	System.out.println(" im here1");
	if(vRetResult != null && vRetResult.size() > 0){
		strPrepareToEdit = "0";
		if(iAction == 0)
			strErrMsg = "Interview result information removed successfully.";
		else if(iAction == 1){
			strErrMsg = "Interview result information added successfully.";

//			System.out.println(" im here2");
		}else if(iAction == 2){
			strErrMsg = "Interview result information changed successfully.";
			strFirstEntry = "0";
		}
	}
	else {
		strErrMsg = hrApplEval.getErrMsg();
	}
	
	vEditInfo = hrApplEval.operateOnInterviewResult(dbOP, request,4);
	
//	System.out.println("vEditInfo : " + vEditInfo);
	
}//end of if vapplication info is not null;

//if it is called for iAction == 3, i have to get Edit Info
// if(strPrepareToEdit.compareTo("1") == 0) {
//	vEditInfo = hrApplEval.operateOnInterviewResult(dbOP, request, 3);
//	if(vEditInfo == null)
//		strErrMsg = hrApplEval.getErrMsg();
//}

strTemp = WI.fillTextValue("appl_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

int  iListCount = 0;



%>
<body bgcolor="#663300" onLoad="FocusID();InstantiateDOJ();" class="bgDynamic">
<form action="./interview_result.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INTERVIEW RESULT ::::</strong></font></div></td>
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
        <table width="92%" border="0" align="center">
          <tr> 
            <td>&nbsp;</td>
            <td width="92%"><table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">
              <tr>
                <td width="20%">Assessed by</td>
                <td>
      <input type="text" name="evaluated_by" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="18" value="<%=WI.fillTextValue("evaluated_by")%>"></td>
                <td><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">(EMPLOYEE ID ONLY)</font></td>
              </tr>
              <% if (vEditInfo != null) 
			strTemp = "";
	   else 
			strTemp = WI.fillTextValue("date_interview");
	%>
              <tr>
                <td height="15">Date evaluated</td>
                <td width="24%" height="15"><%
//if(vEditInfo != null && vEditInfo.size() > 0)
//	strTemp = (String)vRetResult.elementAt(2);
//else
	strTemp = WI.fillTextValue("evaluation_date");
%>
                  <input name="evaluation_date" type= "text" class="textbox"  
 	   onFocus="style.backgroundColor='#D3EBFF'" size="12" value="<%=strTemp%>"
	   onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','evaluation_date','/')" 
	   
				onKeyUp="AllowOnlyIntegerExtn('form_','evaluation_date','/')">
                  <a href="javascript:show_calendar('form_.evaluation_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
                <td width="56%">
<%if(iAccessLevel > 1){%>
				<a href="javascript:AddInterviewer();"><img src="../../../images/add.gif" border="0"></a><font size="1">Click
                  to add  interviewer</font>
<%}%>
				  </td>
              </tr>
              <tr>
                <td height="15" colspan="3">
				
	<% int iCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("list_count"),"0"));
	
		if (vEditInfo != null && vEditInfo.size() > 0)
		vInterviewers = (Vector)vEditInfo.elementAt(1);
		
	if (vInterviewers != null && vInterviewers.size() > 0 && strFirstEntry.equals("0")){
		// set iCount on 1st Entry only.. 
		iCount = 	vInterviewers.size() / 3;
	}
	
	if (iCount > 0) { %>
	       <table width="80%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
               <tr bgcolor="#33CCFF">
                <td width="46%" height="21" class="thinborder"><div align="center"><strong>INTERVIEWER</strong></div></td>
                <td width="36%" class="thinborder"><div align="center"><strong>DATE INTERVIEW </strong></div></td>
                <td width="18%" class="thinborder"><strong>REMOVE</strong></td>
    	        </tr>
              <%
	strErrMsg = null;
	String strInteviewerIndex = null;//this is fee already calculated.
	int iRemoveIndex    = Integer.parseInt(WI.getStrValue(WI.fillTextValue("remove_index"),"-1"));

	String strIntvwrIndex     = null;
	String strDateIntvw = null;

	for(int i=0; i<iCount; ++i)
	{
		if(i == iRemoveIndex)
			continue;

		if( i == iCount -1 && WI.fillTextValue("add_fee").length() > 0) {
			strTemp          = WI.fillTextValue("evaluated_by");
			strDateIntvw      = WI.fillTextValue("evaluation_date");
		}
		else {
			strTemp          = WI.fillTextValue("evaluated_by"+i); 
			strDateIntvw	 = WI.fillTextValue("evaluation_date"+i);
		}
		
		if (strFirstEntry.equals("0") && vInterviewers != null && vInterviewers.size() > 0){
			// overwrite entries;
			strTemp = (String)vInterviewers.elementAt(i*3);
			strDateIntvw = (String)vInterviewers.elementAt(i*3 + 1);
		}		
		
	%>
	     <input type="hidden" name="evaluated_by<%=iListCount%>" value="<%=strTemp%>">
         <input type="hidden" name="evaluation_date<%=iListCount%>" value="<%=WI.getStrValue(strDateIntvw)%>">
             <tr>
                <td height="25" class="thinborder">&nbsp;<%=strTemp%> </td>
                <td class="thinborder">&nbsp;&nbsp;<%=WI.getStrValue(strDateIntvw)%></td>
                <td class="thinborder">
<%if(iAccessLevel == 2){%>
					<a href='javascript:RemoveFeeName("<%=iListCount%>");'><img src="../../../images/delete.gif" border="0"></a>				
<%}%>
					</td>
             </tr>
     <%
	//add here to list, it is safe now.
	++iListCount;
	}
%>
              </table>
                  <%} // end if iCount > 0 %>				  </td>
              </tr>
            </table>              
            </td>
          </tr>
          <tr> 
            <td width="8%">&nbsp;</td>
<%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = WI.getStrValue(vEditInfo.elementAt(2));
	else
		strTemp = WI.fillTextValue("assessment_comments");
%>			
            <td>Assessment:<br>  <textarea name="assessment_comments"
			  cols="50" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>            </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
<%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = WI.getStrValue(vEditInfo.elementAt(3));
	else
		strTemp = WI.fillTextValue("remarks");
%>			
            <td>Comments/Remarks:<br>  <textarea name="remarks" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
			onblur="style.backgroundColor='white'" cols="50" rows="2"><%=strTemp%></textarea>            </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Interview Result (1 = Rated lowest, 10 = Rated highest) 
              : 
              <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(4));
else
	strTemp = WI.fillTextValue("intv_rate");
%> <select name="intv_rate">
                <%
			int iSelected = Integer.parseInt(WI.getStrValue(strTemp, "0"));
			for(int i = 1; i < 11; ++i) {
				if( iSelected == i) {%>
                <option value="<%=i%>" selected><%=i%></option>
                <%}else{%>
                <option value="<%=i%>"><%=i%></option>
                <%}
				}%>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(5));
else
	strTemp = WI.fillTextValue("intv_result");
if(strTemp.equals("0"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%> <input type="radio" name="intv_result" value="0" onClick="ShowHideDOJ(0);" <%=strErrMsg%>>
              REJECTED 
<%
if(strTemp.equals("3"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%> <input type="radio" name="intv_result" value="3" onClick="ShowHideDOJ(0);" <%=strErrMsg%>>
              WAIT LIST 
              <%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%> <input name="intv_result" type="radio" onClick="ShowHideDOJ(1);" value="1"<%=strErrMsg%>>
              ACCEPTED 
              <%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else 
	strErrMsg = "";
%> <input type="radio" name="intv_result" value="2" onClick="ShowHideDOJ(0);"<%=strErrMsg%>>
              RESULT PENDING</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><input type="text" value="PROBABLE DOJ" class="textbox_noborder" name="probable_doj_tb"> 
              <%
if(vEditInfo != null && vEditInfo.size() > 0)
 	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("probable_doj");
%> <input type="hidden" name="page_loaded" value="1"> 
              <input name="probable_doj" type= "text" class="textbox"  
			  onfocus="style.backgroundColor='#D3EBFF'" size="12" value="<%=WI.getStrValue(strTemp)%>"
			onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','probable_doj')" 
			 onKeyUp="AllowOnlyIntegerExtn('form_','probable_doj')"> 
              <a href="javascript:show_calendar('form_.probable_doj');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0" name="hide_doj"></a></td>
          </tr>
        </table>
        <div align="center">
            <% if (iAccessLevel > 1 ){
			if(strPrepareToEdit.compareTo("0") == 0) {%>
            <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
            <font size="1">click to save entries&nbsp;
            <%}else{%>
            <a href='javascript:CancelRecord("<%=WI.fillTextValue("appl_id")%>");'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
            to cancel and clear entries</font></font> <a href="javascript:EditRecord();">
			<img src="../../../images/edit.gif" border="0"></a>
            <font size="1">click to save changes</font>
            <%}
		}//iAccessLevel > 1%>

        </div>
      </td>
    </tr>
<%}//only if applicant infomration exists.
%>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="7">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="7" align="center" bgcolor="#FFFFAA" class="thinborderALL"><strong>INTERVIEW 
        RESULT</strong></td>
    </tr>
    <tr> 
      <td width="12%" height="25" align="center" class="thinborder"><font size="1"><strong>EVALUATED 
        BY (DATE) </strong></font></td>
      <td width="25%" height="25" align="center" class="thinborder"><font size="1"><strong>ASSESSMENT</strong></font></td>
      <td width="28%" align="center" class="thinborder"><font size="1"><strong>COMMENTS</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>RATING</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>INTERVIEW 
        STATUS</strong></font></td>
      <td width="10%" height="25" align="center" class="thinborder"><font size="1"><strong>PROBABLE 
        DOJ</strong></font></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
String[] astrConvertIntvStatus = {"REJECTED","ACCEPTED","PENDING","WL"};
int k = 0;
for(int i = 0; i < vRetResult.size(); i += 7){
	vInterviewers = (Vector)vRetResult.elementAt(i+1);
	strTemp = "";
	
	if ( vInterviewers != null && vInterviewers.size() > 0){
		for ( ; k < vInterviewers.size(); k+=3){
			if (strTemp == null || strTemp.length() == 0){
				strTemp = (String)vInterviewers.elementAt(k)  + 
					WI.getStrValue((String)vInterviewers.elementAt(k+1),"(",")","");
			}else{
				strTemp += "<br>" + (String)vInterviewers.elementAt(k)  + 
					WI.getStrValue((String)vInterviewers.elementAt(k+1),"(",")","");
			}
		}
	}
	
%>
    <tr> 
      <td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td height="25" class="thinborder">
		  <%=WI.getStrValue(vRetResult.elementAt(i + 2),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td align="center" class="thinborder"><%=astrConvertIntvStatus[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td height="25" align="center" class="thinborder"> <%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
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
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">


	<input type="hidden" name="list_count" value="<%=iListCount%>">	
	<input type="hidden" name="add_fee">	
	<input type="hidden" name="remove_index">
	<input type="hidden" name="interviewer_name">

</form>
<script language="javascript">
	ShowHideDOJ(2)
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
